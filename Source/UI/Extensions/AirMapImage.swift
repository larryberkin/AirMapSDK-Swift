//
//  UIImage+AirMap.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/15/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

#if os(OSX)
	public typealias Image = NSImage
#else
import UIKit
	public typealias Image = UIImage
#endif

public class AirMapImage {
	
	static func image(named name: String) -> Image? {
		
		#if os(OSX)
			// TODO:
			return nil
		#else
			return UIImage(named: name, in: AirMapBundle.core, compatibleWith: nil)
		#endif
	}

	public static func flightIcon(_ type: AirMapFlight.FlightType) -> Image? {

		switch type {
		case .past :
			return image(named: "past_flight_marker_icon")
		case .active:
			return image(named: "current_flight_marker_icon")
		case .future:
			return image(named: "future_flight_marker_icon")
		}
	}
	
	#if AIRMAP_TRAFFIC
	public static func trafficIcon(type: AirMapTraffic.TrafficType, heading: Int) -> Image? {

		let direction = heading == 0 ? "" : "_" + AirMapTrafficServiceUtils.directionFromBearing(Double(heading), localized:false)

		switch type {
		case .situationalAwareness:
			return AirMapImage.image(named: "sa_traffic_marker_icon" + direction)
		case .alert:
			return AirMapImage.image(named: "traffic_marker_icon" + direction)
		}
	}
	#endif

}
