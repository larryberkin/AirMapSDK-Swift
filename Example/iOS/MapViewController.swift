//
//  ViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 06/27/2016.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap
import Mapbox

class MapViewController: UIViewController {
	
	@IBOutlet weak var mapView: AirMapMapView!
	
	private let mapLayers: [AirMapLayerType] = [.essentialAirspace, .emergencies]
	private let mapTheme: AirMapMapTheme = .standard
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Configure AirMap
		AirMap.logger.minLevel = .debug
		AirMap.trafficDelegate = self
		AirMap.configuration.distanceUnits = .metric // or .metric
		AirMap.configuration.temperatureUnits = .fahrenheit // or .celcius

		//Configure Map
		mapView.configure(layers: mapLayers, theme: mapTheme)
	
		// Get Aircfraft by Name
		getAirMapAircraft(name: "DJI Phantom Pro 4") { aircraft in
			print(aircraft?.nickname ?? "")
		}

	}
	
	func getAirMapAircraft(name: String, complete: @escaping (AirMapAircraft?) -> Void) {
		
		AirMap.listAircraft { aircraftResult in
			switch aircraftResult {
			case .error:
				complete(nil)
			case .value(let aircrafts):
				if let existingAircraft = aircrafts.filter({ $0.nickname == name }).first {
					complete(existingAircraft)
				} else {
					AirMap.listModels{ modelsResult in
						switch modelsResult {
						case .error:
							complete(nil)
						case .value(let models):
							if let model = models.filter({ $0.name == name }).first {
								let newAircraft = AirMapAircraft()
								newAircraft.model = model
								newAircraft.nickname = name
								complete(newAircraft)
							} else {
								complete(nil)
							}
						}
					}
				}
			}
		}
	}
	
	@IBAction func addFlight() {
		
		if let flightPlanController = AirMap.flightPlanViewController(location: mapView.centerCoordinate, flightPlanDelegate: self, mapTheme: mapTheme, mapLayers: mapLayers) {
			present(flightPlanController, animated: true, completion: nil)
		} else {
			showAuthController()
		}
	}
	
	fileprivate func showAuthController() {
		
		AirMap.login(from: self, with: handleLogin)
	}
	
	fileprivate func handleLogin(result: Result<AirMapPilot>) {
		
		switch result {
		case .error(let error):
			AirMap.logger.error(error)
		case .value(let pilot):
			if pilot.phoneVerified == false {
				let verification = AirMap.phoneVerificationViewController(pilot, phoneVerificationDelegate: self)
				self.present(verification, animated: true, completion: nil)
			} else {
				self.addFlight()
			}
		}
	}
}

extension MapViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismiss(animated: true, completion: nil)
	}
}

extension MapViewController: AirMapFlightPlanDelegate {
	
	func airMapFlightPlanDidEncounter(_ error: Error) {
		AirMap.logger.error(error)
	}
	
	func airMapFlightPlanDidCreate(_ flight: AirMapFlight) {
		mapView.addAnnotation(flight)
		if presentedViewController is AirMapFlightPlanNavigationController {
			dismiss(animated: true, completion: nil)
		}
		let coordinate = mapView.centerCoordinate
		try! AirMap.sendTelemetryData(flight, coordinate: coordinate, altitudeAgl: 100, altitudeMsl: nil)
	}
	
}

extension AirMapTraffic: MGLAnnotation {
	
	public var title: String? {
		return properties.aircraftId
	}
}

extension MapViewController: AirMapTrafficObserver {
	
	func airMapTrafficServiceDidAdd(_ traffic: [AirMapTraffic]) {
		NSLog("%@", traffic)
		mapView.addAnnotations(traffic)
	}
	
	func airMapTrafficServiceDidUpdate(_ traffic: [AirMapTraffic]) {
		// annotations are updated via KVO
	}
	
	func airMapTrafficServiceDidRemove(_ traffic: [AirMapTraffic]) {
		mapView.removeAnnotations(traffic)
	}
	
	func airMapTrafficServiceDidConnect() {
		print("Connected")
	}
	
	func airMapTrafficServiceDidDisconnect() {
		print("Disconnected")
	}
}

extension MapViewController: MGLMapViewDelegate {
	
	func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
		
	}
	
	func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
		if let flight = annotation as? AirMapFlight,
			let flightNav = AirMap.flightPlanViewController(flight) {
			present(flightNav, animated: true, completion: nil)
		}
	}
	
	func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
		
		switch annotation {
			
		case is AirMapFlight:
			let flightIcon = AirMapImage.flightIcon(.active)!
			return MGLAnnotationImage(image: flightIcon, reuseIdentifier: "flightIcon")
			
		case let traffic as AirMapTraffic:
			let trafficIcon = AirMapImage.trafficIcon(type: traffic.trafficType, heading: traffic.trueHeading)!
			return MGLAnnotationImage(image: trafficIcon, reuseIdentifier: traffic.id)
			
		default:
			return nil
		}
	}
	
	func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
		return true
	}
	
}
