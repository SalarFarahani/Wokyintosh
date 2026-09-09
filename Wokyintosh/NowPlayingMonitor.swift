import AppKit
import Foundation

struct NowPlayingData: Codable {
    let playing: Bool
    let app: String
    let track: String
    let artist: String
    let duration: Double
    let position: Double
    let state: String
    let artworkURL: String

    enum CodingKeys: String, CodingKey {
        case playing, app, track, artist, duration, position, state
        case artworkURL = "artwork_url"
    }

    static let empty = NowPlayingData(
        playing: false, app: "", track: "", artist: "",
        duration: 0, position: 0, state: "stopped", artworkURL: ""
    )
}

final class NowPlayingMonitor {
    private var artworkCache: [String: String] = [:]

    func snapshot() -> NowPlayingData {
        if isRunning(bundleID: "com.spotify.client"),
           let spotify = spotifySnapshot() {
            return spotify
        }

        if isRunning(bundleID: "com.apple.Music"),
           let music = musicSnapshot() {
            return music
        }

        return .empty
    }

    private func isRunning(bundleID: String) -> Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
    }

    private func runAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let result = script.executeAndReturnError(&error)
        if error != nil { return nil }
        return result.stringValue
    }

    private func spotifySnapshot() -> NowPlayingData? {
        let script = """
        tell application "Spotify"
            if player state is playing or player state is paused then
                set t to name of current track
                set a to artist of current track
                set d to duration of current track / 1000
                set p to player position
                set s to player state as text
                try
                    set u to artwork url of current track
                on error
                    set u to ""
                end try
                return t & "|||RD|||" & a & "|||RD|||" & d & "|||RD|||" & p & "|||RD|||" & s & "|||RD|||" & u
            end if
        end tell
        return ""
        """

        guard let result = runAppleScript(script), !result.isEmpty else { return nil }
        let parts = result.components(separatedBy: "|||RD|||")
        guard parts.count == 6 else { return nil }

        return NowPlayingData(
            playing: true,
            app: "Spotify",
            track: parts[0],
            artist: parts[1],
            duration: Double(parts[2]) ?? 0,
            position: Double(parts[3]) ?? 0,
            state: parts[4],
            artworkURL: parts[5]
        )
    }

    private func musicSnapshot() -> NowPlayingData? {
        let script = """
        tell application "Music"
            if player state is playing or player state is paused then
                set t to name of current track
                set a to artist of current track
                set d to duration of current track
                set p to player position
                set s to player state as text
                return t & "|||RD|||" & a & "|||RD|||" & d & "|||RD|||" & p & "|||RD|||" & s
            end if
        end tell
        return ""
        """

        guard let result = runAppleScript(script), !result.isEmpty else { return nil }
        let parts = result.components(separatedBy: "|||RD|||")
        guard parts.count == 5 else { return nil }

        let track = parts[0]
        let artist = parts[1]

        return NowPlayingData(
            playing: true,
            app: "Music",
            track: track,
            artist: artist,
            duration: Double(parts[2]) ?? 0,
            position: Double(parts[3]) ?? 0,
            state: parts[4],
            artworkURL: artworkURL(track: track, artist: artist)
        )
    }

    private func artworkURL(track: String, artist: String) -> String {
        let key = "\(artist.lowercased())|\(track.lowercased())"
        if let cached = artworkCache[key] { return cached }

        let semaphore = DispatchSemaphore(value: 0)
        var resultURL = ""

        var components = URLComponents(string: "https://itunes.apple.com/search")!
        components.queryItems = [
            URLQueryItem(name: "term", value: "\(artist) \(track)"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "1")
        ]

        guard let url = components.url else { return "" }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { semaphore.signal() }
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let results = json["results"] as? [[String: Any]],
                let first = results.first,
                var art = first["artworkUrl100"] as? String
            else { return }

            art = art.replacingOccurrences(of: "100x100bb", with: "600x600bb")
            resultURL = art
        }.resume()

        _ = semaphore.wait(timeout: .now() + 2.5)
        artworkCache[key] = resultURL
        return resultURL
    }
}
