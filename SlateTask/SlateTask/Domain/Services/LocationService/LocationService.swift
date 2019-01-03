//
//  LocationService.swift
//  SlateTask
//
//  Created by Anton Sokolchenko on 1/3/19.
//  Copyright © 2019 Sokolchenko. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceObserver {
	// locaiton manager may be a protocol in case we need some flexibility
	func didUpdateLocation(locationManager: LocationService, location: CLLocation)
	func didUpdateMonitoredRegionState(locationManager: LocationService, isInsideMonitoredRegion: Bool)
}

class LocationService: NSObject {

	var observer: LocationServiceObserver?

	private var locationManager = CLLocationManager()

	// at the start of the app
	var initialLocation: CLLocation?
	var lastLocation: CLLocation?

	// for test purpose this is the only one region we'll use
	private var monitoredRegion: MonitoredRegion?
	// this should be an array if we support multiple regions monitoring
	// or convert MonitoredRegion to a class and add lastLocationState(inside, outside)
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
		let region = CLCircularRegion(center: region.regionCenter, radius: region.radius, identifier: region.identifier)
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
		guard let newLocation = locations.last else { return }
		self.initialLocation = newLocation
		self.lastLocation = newLocation
		DispatchQueue.main.async {
			self.observer?.didUpdateLocation(locationManager: self, location: newLocation)
		}
	}

	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		manager.requestState(for: region)
	}

	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		switch state {
		case .inside:
			isInsideMonitoredRegion = true
			DispatchQueue.main.async { [weak self] in
				guard let self = `self` else { return }
				self.observer?.didUpdateMonitoredRegionState(locationManager: self, isInsideMonitoredRegion: self.isInsideMonitoredRegion)
			}

		case .outside:
			isInsideMonitoredRegion = false
			DispatchQueue.main.async { [weak self] in
				guard let self = `self` else { return }
				self.observer?.didUpdateMonitoredRegionState(locationManager: self, isInsideMonitoredRegion: self.isInsideMonitoredRegion)
			}
		case .unknown:
			// we need to decide should we treat this as false or not
			break
		}
	}
}
