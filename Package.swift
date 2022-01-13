// swift-tools-version:5.3
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
