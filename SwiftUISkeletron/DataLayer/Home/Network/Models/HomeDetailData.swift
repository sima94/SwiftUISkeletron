//
//  HomeDetailsData.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//

import Foundation

struct HomeDetailData: Identifiable, Decodable, Sendable {
	var id: UUID = UUID()
	var title: String
	var subtitle: String
	var description: String
}
