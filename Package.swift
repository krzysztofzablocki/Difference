// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Difference",
    products: [
        .library(name: "Difference", targets: ["Difference"])
    ],
    targets: [
        .target(
            name: "Difference",
            path: "Sources"
        ),
        .testTarget(
            name: "DifferenceTests",
            dependencies: ["Difference"],
            path: "Tests/DifferenceTests"
        )
    ]
)
