# AGENTS.md

Guidance for coding agents working in this repository.

## Commits

- One change, one commit. Keep each commit focused on a single logical change.
- Commit messages must be a single line. No body, no trailers.

## Project

- Xcode project: `Buses 2.xcodeproj`, schemes `Buses` (app) and `AssistantExtension` (widgets and Live Activities).
- Deployment target is iOS 26. Folders are file system synchronized groups, so new files are picked up automatically by the target that owns the folder.
- The LTA DataMall key is read from `Buses/APIKeys.plist` (see `APIKeys-Sample.plist`), which is not committed; never commit a real key. The app shares it with the extension through the App Group.
- `Shared/` is compiled into both targets. Put models, API code, Live Activity attributes and intents used by both the app and the extension there.
- The app and extension share data through the App Group `group.com.tsubuzaki.Tsugi2`: favorites (SwiftData), cached transit data, and `UserDefaults.shared`.
- New user-facing strings go into `Buses/Strings/Localizable.xcstrings` with translations for every supported language.

## Building

```sh
xcodebuild -project "Buses 2.xcodeproj" -scheme Buses \
  -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

SwiftLint runs as a build phase; keep new code free of lint warnings.

Unsigned builds have no entitlements, so the App Group, widget configuration and App Intents do not work in them. To test those on a simulator, sign ad hoc instead:

```sh
xcodebuild -project "Buses 2.xcodeproj" -scheme Buses \
  -destination 'generic/platform=iOS Simulator' build \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= PROVISIONING_PROFILE_SPECIFIER=
```
