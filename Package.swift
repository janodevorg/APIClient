// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "APIClient",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "APIClient", type: .static, targets: ["APIClient"]),
        .library(name: "APIClientDynamic", type: .dynamic, targets: ["APIClient"])
    ],
    dependencies: [
        .package(url: "git@github.com:janodevorg/Report.git", from: "1.0.0"),
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "ReportDynamic", package: "Report")
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
