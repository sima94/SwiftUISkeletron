// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "Infuse",
	platforms: [.iOS(.v18), .macOS(.v15)],
	products: [
		.library(name: "Infuse", targets: ["Infuse"]),
	],
	targets: [
		.target(name: "Infuse", path: "Sources"),
		.testTarget(name: "InfuseTests", dependencies: ["Infuse"], path: "Tests"),
	]
)
