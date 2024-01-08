// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let includeMacros = false
let includeDebugTarget = true

let package = Package(
    name: "ExtendedSwift",
    platforms: [
        .macOS(.v13),
        .iOS("16.1"),
        .watchOS("9.1"),
        .tvOS("16.1"),
        .macCatalyst("16.1")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "ExtendedObjC", targets: ["ExtendedObjC"]),
        .library(name: "ExtendedSwift", targets: ["ExtendedSwift"]),
        .library(name: "ExtendedKit", targets: ["ExtendedKit"]),
        
        .library(name: "HTTP", targets: ["HTTP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .target(name: "ExtendedObjC", dependencies: []),
        
        .target(name: "PrivateAPI", dependencies: ["ExtendedObjC"]),
        
        .target(name: "ExtendedSwift",
                dependencies: [
                    "PrivateAPI",
                    .product(name: "Algorithms", package: "swift-algorithms"),
                    .product(name: "Logging", package: "swift-log")
                ],
                resources: [
                    .copy("Resources/entities.json")
                ],
                swiftSettings: [
                    .unsafeFlags(["-enable-bare-slash-regex"])
                ]),
        
        .target(name: "ExtendedKit",
                dependencies: [
                    "ExtendedSwift",
                    "ExtendedObjC",
                    "PrivateAPI",
                    .product(name: "Logging", package: "swift-log")
                ],
                swiftSettings: [
                    .unsafeFlags(["-enable-bare-slash-regex"])
                ]),
        
        .target(name: "ExtendedTest", dependencies: []),
        
        .target(name: "HTTP", 
                dependencies: [
                    "ExtendedSwift"
                ]),
        
        // TEST TARGETS
        
        .testTarget(name: "ExtendedSwiftTests",
                    dependencies: ["ExtendedSwift"],
                    swiftSettings: [
                        .unsafeFlags(["-enable-bare-slash-regex"])
                    ]),
        
        .testTarget(name: "PrivateAPITests", dependencies: ["PrivateAPI"]),
        .testTarget(name: "ExtendedObjCTests", dependencies: ["ExtendedObjC"]),
        .testTarget(name: "HTTPTests", dependencies: ["HTTP", "ExtendedTest"]),
    ]
)


if includeDebugTarget == true {
    package.targets.append(
        .executableTarget(name: "debug",
                          dependencies: [
                            "ExtendedObjC",
                            "ExtendedSwift",
                            "ExtendedKit",
                          ],
                          swiftSettings: [
                            .unsafeFlags(["-enable-bare-slash-regex"])
                          ])
    )
    
    package.products.append(
        .executable(name: "debug", targets: ["debug"])
    )
}

if includeMacros == true {
    package.products.append(contentsOf: [
        .library(name: "ExtendedMacros", targets: ["ExtendedMacros"])
    ])
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-08-15-a"),
        .package(url: "https://github.com/stackotter/swift-macro-toolkit.git", from: "0.2.0")
    ])
    package.targets.append(contentsOf: [
        .macro(
            name: "ExtendedMacrosImpl",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacroToolkit", package: "swift-macro-toolkit")
            ]
        ),

        .target(name: "ExtendedMacros", dependencies: ["ExtendedMacrosImpl"]),
    ])
    
    if includeDebugTarget == true {
        if let target = package.targets.first(where: { $0.type == .executable && $0.name == "debug" }) {
            target.dependencies.append("ExtendedMacros")
        }
    }
}
