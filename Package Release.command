#!/bin/zsh

cd "$(dirname "$0")" || exit 1

ROOT="$PWD"
BUILD_SCRIPT="$ROOT/Build Wokyintosh.command"
APP="$ROOT/build/Wokyintosh.app"
DIST="$ROOT/dist"
OUT="$DIST/Wokyintosh-1.0.0-macOS.zip"

# Create dist immediately so its presence does not depend on the build.
mkdir -p "$DIST"

echo ""
echo "Wokyintosh 1.0 — GitHub Release Packager"
echo "========================================="
echo ""
echo "Project:"
echo "$ROOT"
echo ""
echo "Release folder:"
echo "$DIST"
echo ""

if [ ! -x "$BUILD_SCRIPT" ]; then
  chmod +x "$BUILD_SCRIPT" 2>/dev/null
fi

echo "Step 1/2 — Building Wokyintosh…"
echo ""

"$BUILD_SCRIPT"
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
  echo ""
  echo "ERROR: Wokyintosh build failed."
  echo "The dist folder has been created, but no release ZIP was produced."
  echo ""
  echo "Press Return to close this window."
  read
  exit $BUILD_STATUS
fi

if [ ! -d "$APP" ]; then
  echo ""
  echo "ERROR: Build finished, but Wokyintosh.app was not found at:"
  echo "$APP"
  echo ""
  echo "Press Return to close this window."
  read
  exit 1
fi

echo ""
echo "Step 2/2 — Packaging GitHub release…"
echo ""

rm -f "$OUT"

if ! /usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP" "$OUT"; then
  echo ""
  echo "ERROR: Could not create the release ZIP."
  echo ""
  echo "Press Return to close this window."
  read
  exit 1
fi

if [ ! -f "$OUT" ]; then
  echo ""
  echo "ERROR: Release ZIP was not created."
  echo ""
  echo "Press Return to close this window."
  read
  exit 1
fi

echo ""
echo "SUCCESS"
echo "======="
echo ""
echo "GitHub Release file:"
echo "$OUT"
echo ""
echo "This is the file to upload to GitHub Releases."
echo ""
echo "Note: this build is ad-hoc signed and is NOT Apple-notarized."
echo ""

open "$DIST"

echo "The dist folder has been opened in Finder."
echo ""
echo "Press Return to close this window."
read
