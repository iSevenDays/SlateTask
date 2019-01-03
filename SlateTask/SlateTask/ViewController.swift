//
//  ViewController.swift
//  SlateTask
//
//  Created by Anton Sokolchenko on 1/3/19.
//  Copyright © 2019 Sokolchenko. All rights reserved.
//

import UIKit
import MapKit

// 1. Set initial location or wait
class ViewController: UIViewController {

	@IBOutlet var mapView: MKMapView!
	@IBOutlet weak var textFieldRadius: UITextField!
	// inside/outside
	@IBOutlet weak var stateText: UILabel!

	var mapLocation: CLLocation?
	var circleOverlay: MKCircle?
	var pinOverlay: MKPointAnnotation?
	var monitoredRegion: MonitoredRegion?

	override func viewDidLoad() {
		super.viewDidLoad()
		textFieldRadius.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

		ServiceProvider.instance.locationService.observer = self
		if let location = ServiceProvider.instance.locationService.lastLocation {
			addOrUpdateCircleOverlay(location: location)
			mapLocation = location
		} // else we just wait for location
	}


	private func updateViewForNewSelectedLocation(_ location: CLLocation) {
		addOrUpdateCurrentLocationPin(location: location)
		addOrUpdateCircleOverlay(location: location)
	}

	func updateTrackingForNewSelectedLocation(_ location: CLLocation) {
		updateViewForNewSelectedLocation(location)

		let radius = getRadiusFromTextView()
		let monitoredRegion = MonitoredRegion(regionCenter: location.coordinate, radius: radius, identifier: "monitoredRegion")

		ServiceProvider.instance.locationService.startMonitoring(forRegion: monitoredRegion)
	}

	func getRadiusFromTextView() -> CLLocationDistance {
		if let text = textFieldRadius.text {
			let numberFormatter = NumberFormatter()
			numberFormatter.numberStyle = .decimal
			let number = numberFormatter.number(from: (text.trimmingCharacters(in: .whitespaces)))

			return number?.doubleValue ?? 0
		}
		return 0
	}

	@objc func textFieldDidChange(_ textField: UITextField) {
		if let location = ServiceProvider.instance.locationService.lastLocation {
			addOrUpdateCircleOverlay(location: location)
		}
	}
}

extension ViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is MKCircle {
			let circle = MKCircleRenderer(overlay: overlay)
			circle.strokeColor = .red
			circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
			circle.lineWidth = 1
			return circle
		} else {
			fatalError("Other renderes are not implemented")
		}
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		if annotation is MKUserLocation {
			return nil
		}
		let reuseId = "pinOverlay"

		var pav:MKPinAnnotationView?
		if (pav == nil)
		{
			pav = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pav?.isDraggable = true
			pav?.canShowCallout = true;
			pav?.animatesDrop = true
		}
		else
		{
			pav?.annotation = annotation;
		}
		return pav
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let newCoordinate = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		updateTrackingForNewSelectedLocation(newCoordinate)
	}
}

extension ViewController: LocationServiceObserver {
	func didUpdateLocation(locationManager: LocationService, location: CLLocation) {
		if mapLocation == nil {
			updateTrackingForNewSelectedLocation(location)
			mapLocation = location
		}
	}

	func didUpdateMonitoredRegionState(locationManager: LocationService, isInsideMonitoredRegion: Bool) {
		stateText.text = isInsideMonitoredRegion ? "Inside" : "Outside"
	}
}

// Circle view
extension ViewController {
	func addOrUpdateCircleOverlay(location: CLLocation) {
		if let circle = self.circleOverlay  {
			mapView.removeOverlay(circle)
		}
		addRadiusCircle(location: location)
	}
	private func addRadiusCircle(location: CLLocation){
		self.mapView.delegate = self
		let circle = MKCircle(center: location.coordinate, radius: getRadiusFromTextView())
		self.circleOverlay = circle
		mapView.addOverlay(circle)
		mapView.visibleMapRect = mapView.mapRectThatFits(circle.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5))
	}
}

// Current Location Pin
extension ViewController {
	func addOrUpdateCurrentLocationPin(location: CLLocation) {
		if let pin = pinOverlay {
			pin.coordinate = location.coordinate
		} else {
			addCurrentLocationPin(location: location)
		}
	}
	private func addCurrentLocationPin(location: CLLocation) {
		if let pin = pinOverlay {
			pin.coordinate = location.coordinate
		} else {
			let pin =  MKPointAnnotation()
			pin.coordinate = location.coordinate
			pin.title = "Selected location"
			mapView.addAnnotation(pin)
			pinOverlay = pin
		}
	}
}
