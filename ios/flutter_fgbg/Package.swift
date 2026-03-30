// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_fgbg",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-fgbg", targets: ["flutter_fgbg"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_fgbg",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
