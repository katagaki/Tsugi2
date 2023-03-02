# Buses 2
A carefully designed client for Singapore's transit system

Similar to MyTransport, but better and 100 times smaller to download.

## Why I built this
The project started as Tsugi ([Buses on the App Store](https://apps.apple.com/us/app/buses-for-singapore-transit/id1423653146)), an app that aimed to complement the public transit experience in Singapore. At the time the project was first developed, there were no good public transit companion apps on the App Store for Singapore's transit system (yes, that includes the ones developed by other developers). The codebase for the old Tsugi project was lost after an *incident* with macOS Big Sur.

Now, the project aims to improve on Buses by rewriting the UI in SwiftUI, and improving how API calls and persistent data are handled. New features will also be added, such as the viewing of bus service routes, service alerts, and more robust notifications and Siri shortcuts.

Buses 2 will be built on the iOS 16 API, and will support iOS 16.2 and above.

## What works
- Viewing bus stops and bus arrival times
- Searching bus stops
- Quickly getting information about nearby bus stops
- Adding, reordering, and deleting Locations (previously known as Favorites)
- Additional customization, such as setting the startup tab and app icon
- Arrival notifications
- Live Activities (rudimentary support)
- MRT service map (WebView)
- Localization for English, Japanese, and Chinese

## What's planned
- Viewing of bus service routes
- Service alerts for trains
- MRT service map (native)
- Siri shortcuts
- Support for Home Screen widgets

## What's being decided
- Live Activities (full support with push notifications)
