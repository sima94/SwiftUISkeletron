// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "FormValidator",
	platforms: [.iOS(.v17), .macOS(.v14)],
	products: [
		.library(name: "FormValidator", targets: ["FormValidator"]),
	],
	targets: [
		.target(name: "FormValidator", path: "Sources"),
		.testTarget(name: "FormValidatorTests", dependencies: ["FormValidator"], path: "Tests"),
	]
)
