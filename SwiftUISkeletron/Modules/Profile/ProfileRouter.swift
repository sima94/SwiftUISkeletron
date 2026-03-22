//
//  ProfileRouter.swift
//  SwiftUISkeletron
//

import SwiftUI

// MARK: - Route

enum ProfileRoute: Hashable {
	case settings
	case login
	case register
}

// MARK: - Router

typealias ProfileRouter = Router<ProfileRoute, Never>
