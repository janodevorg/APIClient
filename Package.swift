// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "APIClient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "APIClient", type: .dynamic, targets: ["APIClient"]),
        .library(name: "APIClientStatic", type: .static, targets: ["APIClient"])
    ],
    dependencies: [
        .package(url: "git@github.com:janodevorg/Report.git", branch: "1.0.0"),
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "Report", package: "Report")
            ],
            path: "sources/main"
        ),
        .testTarget(
            name: "APIClientTests",
            dependencies: ["APIClient"],
            path: "sources/tests"
        )
    ]
)
