//
//  GeofenceService.swift
//  SlateTask
//
//  Created by Anton Sokolchenko on 1/3/19.
//  Copyright © 2019 Sokolchenko. All rights reserved.
//

import Foundation
import CoreLocation

protocol GeofenceServiceObserver: class {
	// isInsideMonitoredRegion - if the device is inside the monitored region.
	// it is true when inside GPS area OR wi-fi network
	func didUpdateMonitoredRegionState(geofenceService: GeofenceService, isInsideMonitoredRegion: Bool)
}
class GeofenceService {
	private var locationService: LocationService
	// We will use a dictionary of geofence areas: wifi networks for multiple geofence areas monitoring
	private var monitoredWifiNetwork = ""
	// We will use MulticastDelegate in case many observers are needed
	weak var observer: GeofenceServiceObserver?

	init(locationService: LocationService) {
		self.locationService = locationService
		self.locationService.observers.addDelegate(self)
	}

	func startMonitoring(forRegion region: MonitoredRegion, inWiFiNetwork: String) {
		locationService.startMonitoring(forRegion: region)
		monitoredWifiNetwork = inWiFiNetwork
	}
}

extension GeofenceService: LocationServiceObserver {
	func didUpdateMonitoredRegionState(locationManager: LocationService, isInsideMonitoredRegion: Bool) {
		let insideGeofence = isInsideMonitoredRegion || WiFiInfo.networkName == monitoredWifiNetwork
		observer?.didUpdateMonitoredRegionState(geofenceService: self, isInsideMonitoredRegion: insideGeofence)
	}
}
