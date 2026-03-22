//
//  HomeRouter.swift
//  SwiftUISkeletron
//

import SwiftUI

// MARK: - Route & Sheet

enum HomeRoute: Hashable {
	case details(HomeListData)
}

enum HomeSheet: Identifiable {
	case detailsSheet

	var id: Int {
		switch self {
		case .detailsSheet: return 0
		}
	}
}

// MARK: - Router

typealias HomeRouter = Router<HomeRoute, HomeSheet>
