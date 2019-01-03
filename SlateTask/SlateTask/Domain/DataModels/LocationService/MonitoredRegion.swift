//
//  MonitoredRegion.swift
//  SlateTask
//
//  Created by Anton Sokolchenko on 1/3/19.
//  Copyright © 2019 Sokolchenko. All rights reserved.
//

import Foundation
import CoreLocation

struct MonitoredRegion {
	var regionCenter: CLLocationCoordinate2D
	var radius: CLLocationDistance
	var identifier: String
}
