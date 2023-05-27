# Buses 2

![Banner image depicting the Buses app in 3 languages, and the Locations and bus routes feature.](github/banner.png?raw=true "Buses 2")

A carefully designed client for Singapore's transit system

Similar to MyTransport, but a lot faster and 100 times smaller to download.

## Why I built this
The project started as Tsugi ([Buses on the App Store](https://apps.apple.com/us/app/buses-for-singapore-transit/id1423653146)), an app that aimed to complement the public transit experience in Singapore. 
At the time the project was first developed, there were no good public transit companion apps on the App Store for Singapore's transit system (the official MyTransport app is still a really poor experience, despite their *inspired* UI refresh).
While there are some decent options out there now developed by other developers, I still believe in the Tsugi experience.

The codebase for the old Tsugi project was lost after an incident with macOS Big Sur, leading to this rewrite in SwiftUI. 
The rewrite also aims to improve how API calls and persistent data are handled, by using Core Data and new async/await features. 
New features will also be added, such as the viewing of bus service routes, service alerts, and more robust notifications and Siri shortcuts.

Buses 2 will be built on the iOS 16 API, and will support iOS 16.2 and above.

## Development

### What works
- Viewing bus stops and bus arrival times
- Viewing of bus service routes (with thanks to BusRouter SG for the polyline data)
- Searching bus stops
- Quickly getting information about nearby bus stops
- Adding, reordering, and deleting Locations (previously known as Favorites)
- Additional customization, such as setting the startup tab and app icon
- Arrival notifications
- Live Activities (rudimentary support)
- MRT service map (WebView)
- Localization for English, Japanese, and Chinese

### What's planned
- Deeplinking when tapping notification
- Service alerts for trains
- MRT service map (native)
- Siri shortcuts
- Support for Home Screen widgets

### What's being decided
- Live Activities (full support with push notifications)

## Building

### Step 1: Adding your LTA DataMall account key

If you use Xcode Cloud, you can add your LTA DataMall account key to your environment variables with the key `APIKEY_LTADATAMALL`.

If not, duplicate and rename `APIKeys-Sample.plist` to `APIKeys.plist`, then insert your LTA DataMall account key into the `LTA` key. 

### Step 2: Build with Xcode

Once you have added your LTA DataMall account key, it is only a matter of opening the `Buses2.xcodeproj` Xcode project, and building.
