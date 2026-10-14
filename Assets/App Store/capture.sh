#!/bin/zsh
# Captures raw App Store screenshots into Raw/<language>/.
# Usage: ./capture.sh [languages...]   (defaults to en ja zh-Hans zh-Hant ms)
#
# Each screen is staged by the app itself, which a debug build does when it is
# launched with -ScreenshotScene. Arrivals are live, so run this while buses
# are running in Singapore. Run compose.swift afterwards to frame them.
set -e

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h:h}
BUNDLE_ID=com.tsubuzaki.Tsugi2
DERIVED_DATA=/tmp/buses-screenshots-dd
DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-18-Pro-Max
RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-27-0
LANGUAGES=($@)
(( $# )) || LANGUAGES=(en ja zh-Hans zh-Hant ms)
typeset -A LOCALES=(en en_SG ja ja_JP zh-Hans zh_SG zh-Hant zh_HK ms ms_SG)
# Next to Serangoon Station, where the nearby list fills up with arrivals.
LOCATION=1.3502,103.8732

# name, scene, appearance
SHOTS=(
  "01-nearby nearby light"
  "02-locations locations light"
  "03-route route light"
  "04-search search light"
  "05-bus-stop busStop light"
  "06-dark nearby dark"
)

# MARK: - Simulator

simulator() {
  local name="Buses Screenshots" udid
  udid=$(xcrun simctl list devices available | grep "$name (" | head -1 | grep -oE '[0-9A-F-]{36}' || true)
  if [[ -z $udid ]]; then
    udid=$(xcrun simctl create "$name" $DEVICE_TYPE $RUNTIME)
  fi
  echo $udid
}

# Live Activities and system text follow the system language, not the app's, so
# the whole simulator is switched and restarted for each language. The
# preferences are edited while it is shut down: a `defaults write` through
# simctl spawn does not survive the restart.
boot() {
  local preferences=~/Library/Developer/CoreSimulator/Devices/$1/data/Library/Preferences/.GlobalPreferences.plist
  # The first boot is what creates the preferences.
  xcrun simctl boot $1 2>/dev/null || true
  xcrun simctl bootstatus $1 -b >/dev/null
  xcrun simctl shutdown $1
  plutil -replace AppleLanguages -json "[\"$2\"]" "$preferences"
  plutil -replace AppleLocale -string $LOCALES[$2] "$preferences"
  xcrun simctl boot $1
  xcrun simctl bootstatus $1 -b >/dev/null
  xcrun simctl status_bar $1 override --time 9:41 \
    --batteryState discharging --batteryLevel 100 \
    --cellularMode active --cellularBars 4 --wifiBars 3 --operatorName ""
  xcrun simctl location $1 set $LOCATION
}

launch() {
  xcrun simctl terminate $1 $BUNDLE_ID 2>/dev/null || true
  xcrun simctl launch $1 $BUNDLE_ID -ScreenshotScene $2 >/dev/null
}

# MARK: - Build

# Signed ad hoc so that the App Group works, which holds the transit data cache.
xcodebuild build -project "$PROJECT_DIR/Buses 2.xcodeproj" -scheme Buses -configuration Debug \
  -destination "generic/platform=iOS Simulator" -derivedDataPath $DERIVED_DATA -quiet \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= PROVISIONING_PROFILE_SPECIFIER=
APP=$DERIVED_DATA/Build/Products/Debug-iphonesimulator/Buses.app

# MARK: - Capture

UDID=$(simulator)
fresh_install=1
for language in $LANGUAGES; do
  raw_dir="$SCRIPT_DIR/Raw/$language"
  mkdir -p "$raw_dir"
  boot $UDID $language

  if (( fresh_install )); then
    xcrun simctl uninstall $UDID $BUNDLE_ID 2>/dev/null || true
    xcrun simctl install $UDID $APP
    xcrun simctl privacy $UDID grant location $BUNDLE_ID
    # Bus stops and routes download on first use, and are cached for later launches.
    xcrun simctl ui $UDID appearance light
    launch $UDID route
    sleep 90
    fresh_install=0
  fi

  for shot in $SHOTS; do
    read name scene appearance <<<"$shot"
    xcrun simctl ui $UDID appearance $appearance
    launch $UDID $scene
    # Long enough for arrivals to load and the map and sheet to settle.
    sleep ${SETTLE:-15}
    xcrun simctl io $UDID screenshot "$raw_dir/$name.png" >/dev/null 2>&1
    echo "captured $language/$name"
  done
  xcrun simctl ui $UDID appearance light
done
xcrun simctl terminate $UDID $BUNDLE_ID 2>/dev/null || true
