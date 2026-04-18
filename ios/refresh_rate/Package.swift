// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// This Package.swift file enables Swift Package Manager support for the
// refresh_rate Flutter plugin on iOS. It mirrors the sources and platform
// requirements declared in refresh_rate.podspec.
//
// See: https://docs.flutter.dev/to/spm

import PackageDescription

let package = Package(
    name: "refresh_rate",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "refresh-rate", targets: ["refresh_rate"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "refresh_rate",
            dependencies: [],
            path: "Classes",
            exclude: [],
            sources: nil, // include all .swift, .m, .h sources
            publicHeadersPath: ".",
            swiftSettings: [
                .unsafeFlags(["-import-objc-header", "Classes/DisplayLinkSwizzle.h"],
                             .when(platforms: [.iOS])),
            ]
        ),
    ]
)
