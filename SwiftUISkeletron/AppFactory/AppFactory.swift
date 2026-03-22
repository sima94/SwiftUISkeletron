//
//  AppFactory.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 8.5.25..
//

import Foundation
@preconcurrency import SwiftyBeaver

let log = SwiftyBeaver.self

enum AppFactory {

	static func configure() {
		let console = ConsoleDestination()
		console.logPrintWay = .print
		log.addDestination(console)
	}
}
