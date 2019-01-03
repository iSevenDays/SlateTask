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
// 2. Start tracking default geofence area with the default radius
// 3. When map is moved, update geofence area
// 4. Current location pin location is set in simulator debug settings (Simulator - Debug - Location - Custom location)
class ViewController: UIViewController {

	@IBOutlet var mapView: MKMapView!
	@IBOutlet weak var textFieldRadius: UITextField!
	// Shows label with text "inside" or "outside"
	@IBOutlet weak var stateText: UILabel!

	var geofenceLocation: CLLocation? {
		didSet {
			if let location = geofenceLocation {
				addOrUpdateGeofenceCircleOverlay(location: location)
			}
		}
	}
	
	var geofenceLocationCircleOverlay: MKCircle?
	var currentLocationPinOverlay: MKPointAnnotation?
	var monitoredRegion: MonitoredRegion?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.mapView.delegate = self
		textFieldRadius.delegate = self
		
		textFieldRadius.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

		ServiceProvider.instance.locationService.observers.addDelegate(self)
		ServiceProvider.instance.geofenceService.observer = self

		if let location = ServiceProvider.instance.locationService.lastLocation {
			startTrackingNewGeofenceArea(inLocation: location)
		}

	}

	@IBAction func showCurrentLocation(_ sender: Any) {
		if let currentLocationPinOverlay = currentLocationPinOverlay {
			mapView.showAnnotations([currentLocationPinOverlay], animated: true)
		}
	}

	@IBAction func showGeofenceLocation(_ sender: Any) {
		if let geofenceLocationCircleOverlay = geofenceLocationCircleOverlay {
			showVisibleRect(forMapElement: .circle(geofenceLocationCircleOverlay))
		}
	}

	// Start tracking new geofence area with radius from text field input
	func startTrackingNewGeofenceArea(inLocation location: CLLocation) {
		let radius = getRadiusFromTextView()
		addOrUpdateGeofenceCircleOverlay(location: location)

		let monitoredRegion = MonitoredRegion(regionCenter: location.coordinate, radius: radius, identifier: "monitoredRegion")

		ServiceProvider.instance.geofenceService.startMonitoring(forRegion: monitoredRegion, inWiFiNetwork: "Apple")
	}

	enum MapElement {
		case circle(MKCircle)
	}
	func showVisibleRect(forMapElement element: MapElement) {
		switch element {
		case .circle(let circle):
			mapView.visibleMapRect = mapView.mapRectThatFits(circle.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5))
		}
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
			addOrUpdateGeofenceCircleOverlay(location: location)
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
			fatalError("Other renderers are not implemented")
		}
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		let reuseId = "pinOverlay"
		let pav = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
		pav.isDraggable = true
		pav.canShowCallout = true
		pav.animatesDrop = true

		return pav
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let newCoordinate = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		geofenceLocation = newCoordinate
		startTrackingNewGeofenceArea(inLocation: newCoordinate)
	}
}

extension ViewController: LocationServiceObserver {
	func didUpdateLocation(locationManager: LocationService, location: CLLocation) {
		if geofenceLocation == nil {
			startTrackingNewGeofenceArea(inLocation: location)
			geofenceLocation = location
		}
		addOrUpdateCurrentLocationPin(location: location)
	}
}

extension ViewController: GeofenceServiceObserver {
	func didUpdateMonitoredRegionState(geofenceService: GeofenceService, isInsideMonitoredRegion: Bool) {
		stateText.text = isInsideMonitoredRegion ? "Inside" : "Outside"
		stateText.backgroundColor = isInsideMonitoredRegion ? .green : .red
	}
}

// Circle view
extension ViewController {
	func addOrUpdateGeofenceCircleOverlay(location: CLLocation) {
		if let mapCircle = self.geofenceLocationCircleOverlay  {
			mapView.removeOverlay(mapCircle)
		}
		addGeofenceRadiusCircle(location: location)
	}
	private func addGeofenceRadiusCircle(location: CLLocation){

		let circle = MKCircle(center: location.coordinate, radius: getRadiusFromTextView())
		self.geofenceLocationCircleOverlay = circle
		mapView.addOverlay(circle)
	}
}

// Current Location Pin
extension ViewController {
	func addOrUpdateCurrentLocationPin(location: CLLocation) {
		if let pin = currentLocationPinOverlay {
			pin.coordinate = location.coordinate
		} else {
			addCurrentLocationPin(location: location)
		}
	}

	private func addCurrentLocationPin(location: CLLocation) {
		if let pin = currentLocationPinOverlay {
			pin.coordinate = location.coordinate
		} else {
			let pin =  MKPointAnnotation()
			pin.coordinate = location.coordinate
			pin.title = "Selected location"
			mapView.addAnnotation(pin)
			currentLocationPinOverlay = pin
		}
	}
}

extension ViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
