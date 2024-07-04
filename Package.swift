// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketBase",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PocketBase",
            targets: ["PocketBase"]),
    ],
    dependencies: [
      .package(
          url: "https://github.com/Flight-School/AnyCodable",
          from: "0.6.0"
      ),
      .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
      .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PocketBase",dependencies:["AnyCodable"]),
        .testTarget(
            name: "PocketBaseTests",
            dependencies: ["PocketBase","Quick","Nimble"]),
    ]
)
