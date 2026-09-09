import CoreLocation
import Foundation

struct WeatherData: Codable {
    let temperature: Int
    let weatherCode: Int
    let location: String

    enum CodingKeys: String, CodingKey {
        case temperature
        case weatherCode = "weather_code"
        case location
    }
}

final class WeatherService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((WeatherData) -> Void)?
    private var timeoutWorkItem: DispatchWorkItem?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func current(completion: @escaping (WeatherData) -> Void) {
        self.completion = completion

        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.requestLocation()

        let timeout = DispatchWorkItem { [weak self] in
            self?.fallbackToIP()
        }
        timeoutWorkItem = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: timeout)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        timeoutWorkItem?.cancel()
        guard let location = locations.last else {
            fallbackToIP()
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let name = placemarks?.first?.locality
                ?? placemarks?.first?.subAdministrativeArea
                ?? placemarks?.first?.administrativeArea
                ?? "LOCAL"
            self?.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                locationName: name
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        timeoutWorkItem?.cancel()
        fallbackToIP()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            fallbackToIP()
        }
    }

    private func fallbackToIP() {
        guard let url = URL(string: "https://ipwho.is/") else {
            finishOffline()
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let lat = json["latitude"] as? Double,
                let lon = json["longitude"] as? Double
            else {
                self?.finishOffline()
                return
            }

            let name = (json["city"] as? String)
                ?? (json["region"] as? String)
                ?? "LOCAL"

            self?.fetchWeather(latitude: lat, longitude: lon, locationName: name)
        }.resume()
    }

    private func fetchWeather(latitude: Double, longitude: Double, locationName: String) {
        var c = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        c.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = c.url else {
            finishOffline()
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let current = json["current"] as? [String: Any],
                let temp = current["temperature_2m"] as? Double,
                let code = current["weather_code"] as? Int
            else {
                self?.finishOffline()
                return
            }

            self?.finish(WeatherData(
                temperature: Int(temp.rounded()),
                weatherCode: code,
                location: locationName.uppercased()
            ))
        }.resume()
    }

    private func finishOffline() {
        finish(WeatherData(temperature: 0, weatherCode: -1, location: "LOCAL"))
    }

    private func finish(_ data: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            self?.completion?(data)
            self?.completion = nil
        }
    }
}
