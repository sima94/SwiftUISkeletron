//
//  DependencyContext.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Foundation

/// Determines whether live, test, or preview values are resolved.
///
/// Detection approach based on PointFree's swift-dependencies:
/// - Explicit override via `INFUSE_CONTEXT` env var
/// - Preview detection via `XCODE_RUNNING_FOR_PREVIEWS`
/// - Test detection via XCTest env vars + SPM test runner arguments
public enum DependencyContext: Sendable {
	case live
	case test
	case preview

	/// Auto-detects context. Evaluated once at process start.
	public static let current: DependencyContext = {
		let environment = ProcessInfo.processInfo.environment

		// 1. Explicit override via environment variable
		if let override = environment["INFUSE_CONTEXT"] {
			switch override {
			case "live": return .live
			case "test": return .test
			case "preview": return .preview
			default: break
			}
		}

		// 2. SwiftUI Preview
		if environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
			return .preview
		}

		// 3. Test detection
		if isTesting(environment: environment) {
			return .test
		}

		return .live
	}()

	// MARK: - Private

	private static func isTesting(environment: [String: String]) -> Bool {
		// Xcode test environment variables
		if environment.keys.contains("XCTestConfigurationFilePath") { return true }
		if environment.keys.contains("XCTestBundlePath") { return true }
		if environment.keys.contains("XCTestBundleInjectPath") { return true }
		if environment.keys.contains("XCTestSessionIdentifier") { return true }

		// XCTest framework linked (Xcode test bundles)
		if NSClassFromString("XCTestCase") != nil { return true }

		// SPM swift test runner arguments
		return CommandLine.arguments.contains { argument in
			let url = URL(fileURLWithPath: argument)
			return url.lastPathComponent == "swiftpm-testing-helper"
				|| argument == "--testing-library"
				|| url.lastPathComponent == "xctest"
				|| url.pathExtension == "xctest"
		}
	}
}
