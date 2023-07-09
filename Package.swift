// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExtendedSwift",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9), .tvOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "ExtendedObjC", targets: ["ExtendedObjC"]),
        .library(name: "ExtendedSwift", targets: ["ExtendedSwift"]),
        .library(name: "ExtendedKit", targets: ["ExtendedKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "ExtendedObjC", dependencies: []),
        
        .target(name: "ExtendedSwift",
                dependencies: [
                    "ExtendedObjC",
                    .product(name: "Algorithms", package: "swift-algorithms")
                ],
                resources: [
                    .copy("Resources/entities.json")
                ],
                swiftSettings: [
                    .unsafeFlags(["-enable-bare-slash-regex"])
                ]),
        
        .target(name: "ExtendedKit", dependencies: ["ExtendedSwift", "ExtendedObjC"]),
        
        // TEST TARGETS
        
        .testTarget(name: "ExtendedSwiftTests",
                    dependencies: ["ExtendedSwift"],
                    swiftSettings: [
                        .unsafeFlags(["-enable-bare-slash-regex"])
                    ]),
        
        .testTarget(name: "ExtendedObjCTests", dependencies: ["ExtendedObjC"]),
    ]
)

//#if DEBUG
package.targets.append(
    .executableTarget(name: "debug",
                      dependencies: ["ExtendedObjC", "ExtendedSwift", "ExtendedKit"],
                      swiftSettings: [
                          .unsafeFlags(["-enable-bare-slash-regex"])
                      ])
)

package.products.append(.executable(name: "debug", targets: ["debug"]))
//#endif
