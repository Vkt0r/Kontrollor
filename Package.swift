// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Kontrollor",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/johnsundell/files.git", majorVersion: 1),
        .Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2)
    ]
)
