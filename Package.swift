// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppleEffortScorePicker",
    defaultLocalization: "en",
    platforms: [.iOS(.v12), .watchOS(.v6)], // The package can be imported for lower OS version, but the Views/ APIs are only available on iOS 18+ and watchOS 11+
    products: [
        .library(
            name: "AppleEffortScorePicker",
            targets: ["AppleEffortScorePicker"])
    ],
    targets: [
        .target(name: "AppleEffortScorePicker"),
        .testTarget(
            name: "AppleEffortScorePickerTests",
            dependencies: ["AppleEffortScorePicker"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
