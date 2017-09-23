//
//  AirMapTraffic.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/2/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper
import CoreLocation

@objc open class AirMapTraffic: NSObject {

	public enum TrafficType: Int {
		case alert
		case situationalAwareness
	}

	open var id: String!
	open var direction: Double = 0
	open var altitude: Double = 0
	open var groundSpeed: Knots = 0
	open var trueHeading: Int = 0
	open var timestamp: Date = Date()
	open var recordedTime: Date = Date()
	open var properties = AirMapTrafficProperties()
	open var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	open var initialCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	open var createdAt: Date = Date()
	open var trafficType = TrafficType.situationalAwareness {
		willSet {
			trafficTypeDidChangeToAlert =  trafficType == .situationalAwareness && newValue == .alert
		}
	}
	open var trafficTypeDidChangeToAlert = false

	public override init() {
		super.init()
		
	}

	public required init?(map: Map) {}

	open func isExpired() -> Bool {
		let expirationInterval = Config.AirMapTraffic.expirationInterval
		return createdAt.addingTimeInterval(expirationInterval).lessThanDate(Date())
	}

	open override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? AirMapTraffic {
			return object.properties.aircraftId == self.properties.aircraftId
		} else {
			return false
		}
	}
}

extension AirMapTraffic: Mappable {

	public func mapping(map: Map) {

		let dateTransform = CustomDateFormatTransform(formatString: Config.AirMapApi.dateFormat)

		id            <-  map["id"]
		direction     <- (map["direction"], StringToDoubleTransform())
		altitude      <- (map["altitude"], StringToDoubleTransform())
		groundSpeed   <- (map["ground_speed_kts"], StringToDoubleTransform())
		trueHeading   <- (map["true_heading"], StringToIntTransform())
		properties    <-  map["properties"]
		timestamp     <- (map["timestamp"], dateTransform)
		recordedTime  <- (map["recorded_time"], dateTransform)

		var latitude: String!
		var longitude: String!
		latitude      <-  map["latitude"]
		longitude     <-  map["longitude"]

		if let lat = Double(latitude), let lng = Double(longitude) {
			initialCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
			coordinate = initialCoordinate
		}
	}
}

extension AirMapTraffic {

	open override var description: String {
		
		let lengthFormatter = LengthFormatter()
		lengthFormatter.unitStyle = .medium
		lengthFormatter.numberFormatter.maximumFractionDigits = 0

		let timeFormatter = DateComponentsFormatter()
		timeFormatter.allowsFractionalUnits = false
		timeFormatter.allowedUnits = [.minute, .second]
		timeFormatter.unitsStyle = .abbreviated
		
		let speedFormatter = NumberFormatter()
		speedFormatter.maximumFractionDigits = 0
		
		let altitudeString: String
		let localizedGroundSpeedString: String

		let localizedUnits = LocalizedStrings.Units.self

		lengthFormatter.numberFormatter.roundingIncrement = 50
		switch AirMap.configuration.distanceUnits {
		case .metric:
			let meters = altitude.meters
			let groundSpeedMpsString = speedFormatter.string(from: NSNumber(value: groundSpeed.metersPerSecond))!
			localizedGroundSpeedString = String(format: localizedUnits.speedFormatMetersPerSecond, groundSpeedMpsString)
			altitudeString = lengthFormatter.string(fromValue: meters, unit: .meter)
		case .imperial:
			let feet = altitude
			let groundSpeedKnotsString = speedFormatter.string(from: NSNumber(value: groundSpeed))!
			localizedGroundSpeedString = String(format: localizedUnits.speedFormatKnots, groundSpeedKnotsString)
			altitudeString = lengthFormatter.string(fromValue: feet, unit: .foot)
		}
		
		let aircraftId = properties.aircraftId ?? ""

		if let flightLocation = AirMap.trafficService.currentFlightLocation() {

			let trafficLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let direction = flightLocation.initialDirectionToLocation(trafficLocation)
			
			let distance = trafficLocation.distance(from: flightLocation)
			let distanceString: String

			switch AirMap.configuration.distanceUnits {
			case .metric:
				if distance < 950 {
					lengthFormatter.numberFormatter.roundingIncrement = 100
					lengthFormatter.numberFormatter.maximumFractionDigits = 0
					distanceString = lengthFormatter.string(fromValue: distance, unit: .meter)
				} else {
					lengthFormatter.numberFormatter.roundingIncrement = 0.5
					lengthFormatter.numberFormatter.maximumFractionDigits = 1
					distanceString = lengthFormatter.string(fromValue: distance/1000, unit: .kilometer)
				}
			case .imperial:
				lengthFormatter.numberFormatter.roundingIncrement = 0.5
				lengthFormatter.numberFormatter.maximumFractionDigits = 1
				let miles = distance.nauticalMiles
				distanceString = lengthFormatter.string(fromValue: miles, unit: .mile)
			}

			// Set timestring to unknown
			var timeString = ""
			
			// GroundSpeed must be grater than zero when calculating secondsFromDistanceAndSpeed
			if groundSpeed > 0 {
				let seconds = Int(AirMapTrafficServiceUtils.secondsFromDistanceAndSpeed(distance, speedInKts: groundSpeed))
				timeString = timeFormatter.string(from: DateComponents(second: seconds))!
			}
			
			let alertFormat = LocalizedStrings.Traffic.alertWithAircraftIdAndDistanceFormat
			return String(format: alertFormat, aircraftId, altitudeString, distanceString, direction, timeString)
			
		} else {

			let alertFormat = LocalizedStrings.Traffic.alertWithAircraftIdFormat
			return String(format: alertFormat, aircraftId, altitudeString, localizedGroundSpeedString)
		}
	}
}
