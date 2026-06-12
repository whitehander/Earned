// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Earned",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Earned", targets: ["EarnedMac"])
    ],
    targets: [
        .target(name: "EarnedCore"),
        .executableTarget(
            name: "EarnedMac",
            dependencies: ["EarnedCore"]
        ),
        .testTarget(
            name: "EarnedCoreTests",
            dependencies: ["EarnedCore"]
        ),
    ]
)
