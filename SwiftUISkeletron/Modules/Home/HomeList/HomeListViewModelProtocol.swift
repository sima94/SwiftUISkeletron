//
//  HomeListViewModelProtocol.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 13.5.25..
//

import Foundation

@MainActor
protocol HomeListViewModelProtocol {
	var title: String { get }
	var isLoading: Bool { get }
	var data: [HomeListData] { get }
	var error: Error? { get }

	func startObserving()
	func fetchData() async
}

