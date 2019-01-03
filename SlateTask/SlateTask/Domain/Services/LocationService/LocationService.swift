//
//  LocationService.swift
//  SlateTask
//
//  Created by Anton Sokolchenko on 1/3/19.
//  Copyright © 2019 Sokolchenko. All rights reserved.
//

import Foundation
import CoreLocation

struct MonitoredRegion {
	var monitoredRegionCenter: CLLocationCoordinate2D
	var radius: CLLocationDistance
	var identifier: String = "monitoredRegion"
}

class LocationService: NSObject {

	private var locationManager = CLLocationManager()

	// at the start of the app
	var initialLocation: CLLocation?
	var lastLocation: CLLocation?

	// for test purpose this is the only one region we'll use
	private var monitoredRegion: MonitoredRegion?
	private var isInsideMonitoredRegion = false

	override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		locationManager.distanceFilter = kCLDistanceFilterNone
		// get best available location becase we don't know the activity type
		locationManager.activityType = .fitness
		// Request always for regions monitoring
		locationManager.requestAlwaysAuthorization()

		stopRegionsMonitoring()
		startUpdatingLocation()
	}

	func stopRegionsMonitoring() {
		for region in locationManager.monitoredRegions {
			locationManager.stopMonitoring(for: region)
		}
	}

	func startUpdatingLocation() {
		locationManager.startUpdatingLocation()
	}

	func startMonitoring(forRegion region: MonitoredRegion) {
		if monitoredRegion != nil {
			stopRegionsMonitoring()
		}
		monitoredRegion = region
		let region = CLCircularRegion(center: region.monitoredRegionCenter, radius: region.radius, identifier: region.identifier)
		region.notifyOnExit = true
		region.notifyOnEntry = true
		locationManager.startMonitoring(for: region)
	}

}

extension LocationService: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard locations.count != 0 else {
			return
		}
		self.initialLocation = locations.last
		self.lastLocation = locations.last

	}

	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		manager.requestState(for: region)
	}

	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		switch state {
		case .inside:
			isInsideMonitoredRegion = true
		case .outside:
			isInsideMonitoredRegion = false
		case .unknown:
			// we need to decide should we treat this as false or not
			break
		}
	}
}
