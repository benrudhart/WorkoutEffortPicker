// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkoutEffortPicker",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .watchOS(.v6)], // The package can be imported for lower OS version, but the Views/ APIs are only available on iOS 18+ and watchOS 11+
    products: [
        .library(
            name: "WorkoutEffortPicker",
            targets: ["WorkoutEffortPicker"])
    ],
    targets: [
        .target(name: "WorkoutEffortPicker"),
        .testTarget(
            name: "WorkoutEffortPickerTests",
            dependencies: ["WorkoutEffortPicker"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
