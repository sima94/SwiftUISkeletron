//
//  DependencyContext.swift
//  Infuse
//
//  Created by Stefan Simic on 19. 3. 2026..
//

import Foundation

/// Determines whether live or test values are resolved.
public enum DependencyContext: Sendable {
	case live
	case test

	/// Auto-detects context based on the running process.
	/// Returns `.test` when running inside XCTest or Swift Testing.
	public static var current: DependencyContext {
		// Xcode test targets
		if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
			return .test
		}
		if ProcessInfo.processInfo.environment["XCTestBundlePath"] != nil {
			return .test
		}
		// XCTest linked (Xcode test bundles)
		if NSClassFromString("XCTestCase") != nil {
			return .test
		}
		// SPM swift test (executable runs from .build directory)
		if let execPath = CommandLine.arguments.first,
		   execPath.contains(".build") {
			return .test
		}
		return .live
	}
}
