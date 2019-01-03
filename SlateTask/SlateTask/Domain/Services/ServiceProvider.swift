//
//  ServiceProvider.swift
//  SlateTask
//
//  Created by Anton Sokolchenko on 1/3/19.
//  Copyright © 2019 Sokolchenko. All rights reserved.
//

import Foundation


// Class purpose is to store services
class ServiceProvider {
	static let instance = ServiceProvider()

	let locationService = LocationService()

}
