// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SamUtils",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // 提供整體框架，讓使用者可以選擇性引用某些功能
        .library(
            name: "SamUtils",
            targets: ["SamUtils_Common","SamUtils_Extension", "SamUtils_API", "SamUtils_Bluetooth", "SamUtils_SwiftUI"]
        ),
        
        // 個別引入
        .library(name: "SamUtils_Common", targets: ["SamUtils_Common"]),
        .library(name: "SamUtils_Extension", targets: ["SamUtils_Extension"]),
        .library(name: "SamUtils_API", targets: ["SamUtils_API"]),
        .library(name: "SamUtils_Bluetooth", targets: ["SamUtils_Bluetooth"]),
        .library(name: "SamUtils_SwiftUI", targets: ["SamUtils_SwiftUI"])
    ],
    dependencies: [
        // 如果有外部依賴，像是 Alamofire，應該在這裡引入
        .package(url: "https://github.com/Alamofire/Alamofire", .exact("5.10.2")),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", .exact("7.0.0"))
    ],
    targets: [
        .target(
            name: "SamUtils_Common",
            path: "SamUtils",
            sources: [
                "GlobalUtils.swift"
            ]
        ),
        // Extension 模組
        .target(
            name: "SamUtils_Extension",
            dependencies: [
                .product(name: "SwifterSwift", package: "SwifterSwift"),
                .target(name: "SamUtils_Common")
            ],
            path: "SamUtils",
            sources: [
                "Extensions"
            ]
        ),
        
        // API 模組
        .target(
            name: "SamUtils_API",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .target(name: "SamUtils_Common")
            ],
            path: "SamUtils",
            sources: [
                "API"
            ]
        ),
        
        // Bluetooth 模組
        .target(
            name: "SamUtils_Bluetooth",
            dependencies: [
                .target(name: "SamUtils_Common")
            ],
            path: "SamUtils",
            sources: [
                "Bluetooth"
            ]
        ),
        
        // SwiftUI 模組
        .target(
            name: "SamUtils_SwiftUI",
            dependencies: [
                .product(name: "SwifterSwift", package: "SwifterSwift"),
                .target(name: "SamUtils_Common")
            ],
            path: "SamUtils",
            sources: [
                "SwiftUITools/Extensions"
            ]
        )
    ]
)
