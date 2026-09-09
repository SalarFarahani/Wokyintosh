# Wokyintosh

**A retro Macintosh-inspired system monitor for macOS.**

Wokyintosh is a native macOS dashboard built for Team Wokyis. It combines live system information, weather, and Now Playing data in a playful classic-Mac-inspired interface.

![Wokyintosh icon](assets/wokyintosh-icon.png)

## Features

- Live CPU usage
- Live RAM usage
- SSD usage
- Network activity
- Apple Music Now Playing
- Spotify Now Playing
- Album artwork
- Local weather
- Automatic light and dark appearance based on macOS
- Retro Macintosh-inspired UI
- Short classic-Mac-style startup screen
- Native macOS app using AppKit + WebKit

## Requirements

- macOS 13 Ventura or later
- Apple Command Line Tools to build from source
- Location permission for local weather
- Automation permission for Apple Music / Spotify Now Playing

## Build

1. Download or clone this repository.
2. Double-click `Build Wokyintosh.command`.
3. If macOS asks for permission to run it, approve it.
4. The script builds the app at:

   `build/Wokyintosh.app`

5. Wokyintosh will open automatically after a successful build.

The build uses Apple's Command Line Tools and does **not** require the full Xcode application.

The build script also removes Finder metadata/resource forks before code signing, which avoids common signing failures after extracting the project in Finder.

## Create a GitHub Release build

On a Mac, double-click:

`Package Release.command`

Keep the Terminal window open until it reports `SUCCESS`. The script creates the `dist` folder immediately, builds Wokyintosh, packages the app, and opens `dist` in Finder. It creates:

`dist/Wokyintosh-1.0.0-macOS.zip`

That ZIP is the recommended asset to attach to the GitHub Release.

## Important: unsigned / unnotarized release

Wokyintosh 1.0 is currently distributed without an Apple Developer ID and is not notarized by Apple.

Because of that, macOS Gatekeeper may block the first launch after download.

If that happens:

1. Move `Wokyintosh.app` to Applications.
2. Control-click or right-click the app and choose **Open**.
3. If macOS still blocks it, open **System Settings → Privacy & Security** and use **Open Anyway** for Wokyintosh.

Only bypass Gatekeeper for a copy of Wokyintosh you downloaded from this official repository.

## Privacy

Wokyintosh runs locally on your Mac.

- System statistics are read locally.
- Weather uses your approximate location when permission is granted.
- Now Playing reads playback information from Apple Music or Spotify through macOS automation.
- Wokyintosh does not include an account system or analytics in version 1.0.

## Version

**Wokyintosh 1.0 — September 2026**

Built by Salar Farahani.

> Wokyintosh — A Mac System Monitor for Team Wokyis, by Salar Farahani ;-)

## License

Wokyintosh is released under the MIT License. See [LICENSE](LICENSE).
