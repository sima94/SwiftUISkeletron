//
//  HomeDetailsViewModelProtocol.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 13.5.25..
//

import Foundation

@MainActor
protocol HomeDetailsViewModelProtocol {

	var isLoading: Bool { get }
	var data: String? { get }

	func fetchData() async
}
