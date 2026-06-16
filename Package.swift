// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Alarma",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "Alarma", targets: ["AlarmaTarget"])
    ],
    targets: [
        .executableTarget(
            name: "AlarmaTarget",
            dependencies: [],
            path: "Alarma"
        )
    ]
)
