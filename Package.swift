// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Eolmabeom",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "EolmabeomMac", targets: ["EolmabeomMac"])
    ],
    targets: [
        .target(name: "EolmabeomCore"),
        .executableTarget(
            name: "EolmabeomMac",
            dependencies: ["EolmabeomCore"]
        ),
        .testTarget(
            name: "EolmabeomCoreTests",
            dependencies: ["EolmabeomCore"]
        ),
    ]
)
