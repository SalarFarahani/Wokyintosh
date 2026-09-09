<div align="center">

<img src="assets/wokyintosh-icon.png" width="180" alt="Wokyintosh app icon">

# Wokyintosh

### A retro Macintosh-inspired system monitor for macOS.

A small native macOS dashboard for live system stats, weather, and Now Playing — designed to feel at home on a retro Mac-inspired setup.

[**Download Wokyintosh 1.0.0**](https://github.com/SalarFarahani/Wokyintosh/releases/tag/v1.0.0)

</div>

---

## Why I built Wokyintosh

After several months of owning a **Wokyis M5 Retro Dock Station**, I still couldn't find the dashboard/widget I actually wanted for its display — not even a paid one.

So I decided to build it myself.

With the help of **ChatGPT** and a vibe-coding approach, that idea became **Wokyintosh**: a small native macOS system monitor designed around the kind of retro dashboard I wanted to see on my own setup.

It started as a personal project for my M5 Retro Dock Station, but I decided to make it public in case other Mac users were looking for something similar.

> Wokyintosh — A Mac System Monitor for Team Wokyis, by Salar Farahani ;-)

## Features

- Live CPU usage
- Live RAM usage
- SSD usage
- Network activity
- Apple Music Now Playing
- Spotify Now Playing
- Album artwork
- Local weather
- Automatic light / dark appearance following macOS
- Short classic-Mac-inspired startup screen
- Retro Macintosh-inspired interface
- Native macOS app built with AppKit + WebKit

## Download

### Latest release

**[Download Wokyintosh 1.0.0](https://github.com/SalarFarahani/Wokyintosh/releases/tag/v1.0.0)**

Requires **macOS 13 Ventura or later**.

### Installation

1. Download `Wokyintosh-1.0.0-macOS.zip` from the latest release.
2. Extract the ZIP.
3. Move `Wokyintosh.app` to your Applications folder.
4. Open Wokyintosh.

### Gatekeeper notice

Wokyintosh 1.0 is currently distributed without an Apple Developer ID and is **not notarized by Apple**.

Because of this, macOS may block the first launch.

If that happens:

1. Control-click or right-click `Wokyintosh.app`.
2. Choose **Open**.
3. If macOS still blocks it, go to **System Settings → Privacy & Security**.
4. Choose **Open Anyway** for Wokyintosh.

Only bypass Gatekeeper for a copy downloaded from this official repository.

## Permissions

Wokyintosh may request:

- **Location** — used to display local weather.
- **Automation access** — used to read Now Playing information from Apple Music or Spotify.

## Privacy

Wokyintosh is designed to run locally on your Mac.

- System statistics are read locally.
- No Wokyintosh account is required.
- Version 1.0 does not include analytics.
- Weather uses your approximate location when permission is granted.
- Playback information is read locally through macOS automation.

## Build from source

If you'd rather build Wokyintosh yourself:

1. Clone or download this repository.
2. Run `Build Wokyintosh.command`.
3. The resulting app will be created at `build/Wokyintosh.app`.

The current build workflow uses Apple's Command Line Tools and does not require the full Xcode application.

## Built with

- Swift
- AppKit
- WebKit / WKWebView
- Core Location
- Native macOS system APIs
- AppleScript integration for Apple Music and Spotify
- ChatGPT-assisted vibe coding

## Roadmap

Some ideas for future versions:

- User-configurable settings
- Manual theme controls
- Better display and window controls
- More dashboard customization
- Easier installation and distribution
- Further UI polish

## Feedback

Found a bug or have an idea?

Use [GitHub Issues](https://github.com/SalarFarahani/Wokyintosh/issues).

Bug reports, feature requests, and suggestions are welcome.

## License

Wokyintosh is released under the [MIT License](LICENSE).

---

<div align="center">

Made for macOS by **Salar Farahani**

</div>
