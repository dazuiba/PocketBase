// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "PocketBase",
//    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    platforms: [
      .iOS(.v13),
      .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PocketBase",
            targets: ["PocketBase"]),
    ],
    dependencies: [
      .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.1.0")),
    ],
    targets: [
        .target(
            name: "PocketBase",dependencies:["ObjectMapper"]),
        .testTarget(
            name: "PocketBaseTests",
            dependencies: ["PocketBase","ObjectMapper"]//,//"AnyCodable","DictionaryCoder"
        ),
        .executableTarget(
          name: "PocketBasePlayground",
          dependencies: [
            "PocketBase",
          ],
          path: "Playground"
        )
    ]
)
