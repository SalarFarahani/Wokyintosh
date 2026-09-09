#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")"
ROOT="$PWD"
SRC="$ROOT/Wokyintosh"
OUT="$ROOT/build"
APP="$OUT/Wokyintosh.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo ""
echo "Wokyintosh 1.0 — Native macOS build"
echo "=================================="
echo ""

if ! command -v xcrun >/dev/null 2>&1; then
  echo "Apple Command Line Tools are required."
  xcode-select --install || true
  exit 1
fi

SWIFTC="$(xcrun --find swiftc 2>/dev/null || true)"
SDK="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"

if [ -z "$SWIFTC" ] || [ ! -x "$SWIFTC" ]; then
  echo "Swift compiler was not found."
  echo "Install/update Apple's Command Line Tools, then try again."
  exit 1
fi

if [ -z "$SDK" ] || [ ! -d "$SDK" ]; then
  echo "macOS SDK was not found in the active Command Line Tools."
  echo "Run: xcode-select --install"
  exit 1
fi

ARCH="$(uname -m)"
TARGET="${ARCH}-apple-macos13.0"

echo "Swift compiler: $SWIFTC"
echo "SDK: $SDK"
echo "Target: $TARGET"
echo ""

rm -rf "$OUT"
mkdir -p "$MACOS" "$RESOURCES/Resources"

echo "Compiling native Wokyintosh…"

"$SWIFTC" \
  -O \
  -sdk "$SDK" \
  -target "$TARGET" \
  -framework AppKit \
  -framework WebKit \
  -framework CoreLocation \
  "$SRC/main.swift" \
  "$SRC/AppDelegate.swift" \
  "$SRC/NativeBridge.swift" \
  "$SRC/SystemMonitor.swift" \
  "$SRC/NowPlayingMonitor.swift" \
  "$SRC/WeatherService.swift" \
  -o "$MACOS/Wokyintosh"

chmod +x "$MACOS/Wokyintosh"

echo "Assembling app bundle…"

cp "$SRC/Info.plist" "$CONTENTS/Info.plist"
cp "$SRC/Resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"
cp "$SRC/Resources/index.html" "$RESOURCES/Resources/index.html"
cp "$SRC/Resources/style.css" "$RESOURCES/Resources/style.css"
cp "$SRC/Resources/app.js" "$RESOURCES/Resources/app.js"

# Remove Finder metadata/resource forks before signing.
# These can be added when files are copied/extracted in Finder and cause
# codesign to fail with "resource fork, Finder information, or similar
# detritus not allowed".
echo "Cleaning macOS metadata…"
/usr/bin/xattr -cr "$APP" 2>/dev/null || true
/usr/bin/find "$APP" -name '._*' -delete 2>/dev/null || true
/usr/bin/dot_clean -m "$APP" 2>/dev/null || true

# Ad-hoc sign the local build so macOS treats it as a coherent app bundle.
if command -v codesign >/dev/null 2>&1; then
  echo "Signing Wokyintosh…"
  codesign --force --deep --sign - \
    --entitlements "$SRC/Wokyintosh.entitlements" \
    "$APP"
fi

# Remove quarantine once more after assembly/signing.
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

echo ""
echo "Build successful:"
echo "$APP"
echo ""
echo "Opening Wokyintosh…"
pkill -x Wokyintosh 2>/dev/null || true
sleep 1
open -n "$APP"
sleep 3
if pgrep -x Wokyintosh >/dev/null 2>&1; then
  echo "Wokyintosh launched."
  echo ""
else
  echo "Wokyintosh exited immediately."
  echo "Run:"
  echo "$APP/Contents/MacOS/Wokyintosh"
fi
