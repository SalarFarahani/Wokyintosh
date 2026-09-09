import Foundation
import WebKit

final class NativeBridge {
    private weak var webView: WKWebView?
    private let systemMonitor = SystemMonitor()
    private let nowPlaying = NowPlayingMonitor()
    private let weather = WeatherService()

    private var systemTimer: Timer?
    private var musicTimer: Timer?
    private var weatherTimer: Timer?

    init(webView: WKWebView) {
        self.webView = webView
    }

    func start() {
        pushSystem()
        pushNowPlaying()
        pushWeather()

        systemTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { [weak self] _ in
            self?.pushSystem()
        }
        musicTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { [weak self] _ in
            self?.pushNowPlaying()
        }
        weatherTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            self?.pushWeather()
        }

        RunLoop.main.add(systemTimer!, forMode: .common)
        RunLoop.main.add(musicTimer!, forMode: .common)
        RunLoop.main.add(weatherTimer!, forMode: .common)
    }

    func stop() {
        systemTimer?.invalidate()
        musicTimer?.invalidate()
        weatherTimer?.invalidate()
    }

    private func pushSystem() {
        let data = systemMonitor.snapshot()
        send(function: "window.WokyintoshNative.updateSystem", payload: data)
    }

    private func pushNowPlaying() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let data = self?.nowPlaying.snapshot() ?? NowPlayingData.empty
            self?.send(function: "window.WokyintoshNative.updateNowPlaying", payload: data)
        }
    }

    private func pushWeather() {
        weather.current { [weak self] data in
            self?.send(function: "window.WokyintoshNative.updateWeather", payload: data)
        }
    }

    private func send<T: Encodable>(function: String, payload: T) {
        guard let json = encode(payload) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.webView?.evaluateJavaScript("\(function)(\(json));", completionHandler: nil)
        }
    }

    private func encode<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        guard
            let data = try? encoder.encode(value),
            let string = String(data: data, encoding: .utf8)
        else { return nil }
        return string
    }
}
