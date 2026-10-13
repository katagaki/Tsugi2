# AGENTS.md

Guidance for coding agents working in this repository.

## Commits

- One change, one commit. Keep each commit focused on a single logical change.
- Commit messages must be a single line. No body, no trailers.

## Project

- Xcode project: `Buses 2.xcodeproj`, schemes `Buses` (app) and `AssistantExtension` (widgets and Live Activities).
- Deployment target is iOS 26. Folders are file system synchronized groups, so new files are picked up automatically by the target that owns the folder.
- The LTA DataMall key is read from `Buses/APIKeys.plist` (see `APIKeys-Sample.plist`), which is not committed.

## Building

```sh
xcodebuild -project "Buses 2.xcodeproj" -scheme Buses \
  -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

SwiftLint runs as a build phase; keep new code free of lint warnings.
