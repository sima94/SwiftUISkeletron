// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "NetworkRelay",
	platforms: [.iOS(.v18), .macOS(.v15)],
	products: [
		.library(name: "NetworkRelay", targets: ["NetworkRelay"]),
	],
	targets: [
		.target(name: "NetworkRelay", path: "Sources"),
		.testTarget(name: "NetworkRelayTests", dependencies: ["NetworkRelay"], path: "Tests"),
	]
)
