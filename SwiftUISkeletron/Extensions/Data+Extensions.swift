//
//  Data+Extensions.swift
//  SwiftUISkeletron
//
//  Created by Stefan Simic on 29.4.25..
//
import Foundation

extension Data {
	var prettyJson: String? {
		String(data: self, encoding:.utf8)
	}
}
