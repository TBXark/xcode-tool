// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xct",
    products: [
        .executable(name: "xct", targets: ["xct"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.18.0")),
        .package(name: "JsonMapper", url: "https://github.com/TBXark/JsonMapper.git", .upToNextMajor(from: "1.2.0"))

	],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "xct",
            dependencies: [
                .product(name: "XcodeProj", package: "XcodeProj"),
                .product(name: "JsonMapper", package: "JsonMapper"),
            ]),
        .testTarget(
            name: "xctTests",
            dependencies: ["xct"]),
    ]
)
