// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xct",
    products: [
        .executable(name: "xct", targets: ["xct"])
    ],
    dependencies: [
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.18.0")),
        .package(name: "JsonMapper", url: "https://github.com/TBXark/JsonMapper.git", .upToNextMajor(from: "1.4.0"))
	],
    targets: [
        .target(
            name: "xct",
            dependencies: [
                .product(name: "XcodeProj", package: "XcodeProj"),
                .product(name: "JsonMapper", package: "JsonMapper")
            ]),
        .testTarget(
            name: "xctTests",
            dependencies: ["xct"])
    ]
)
