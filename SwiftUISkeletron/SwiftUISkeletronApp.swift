//
//  SwiftUISkeletronApp.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import SwiftUI

@main
struct SwiftUISkeletronApp: App {

	init() {
		AppFactory.configure()
	}

	var body: some Scene {
		WindowGroup {
			AppTabView()
		}
	}
}
