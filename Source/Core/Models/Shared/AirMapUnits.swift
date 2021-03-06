//
//  AirMapUnits.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 2/7/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

import Foundation

public enum DistanceUnits {
	case metric
	case imperial
}

public typealias Feet = Double
public typealias Meters = Double
public typealias Kilometers = Double
public typealias StatuteMiles = Double
public typealias NauticalMiles = Double
public typealias Acres = Double
public typealias Hectares = Double

public extension Feet {
	
	public static let metersPerFoot: Meters = 1/3.28084

	public var meters: Meters {
		return self * Feet.metersPerFoot
	}
}

public extension Meters {
	
	public static let metersPerNauticalMile: Meters = 1852.0
	public static let metersPerStatuteMile: Meters = 1609.34

	public var nauticalMiles: NauticalMiles {
		return self / Meters.metersPerNauticalMile
	}
	
	public var feet: Feet {
		return self / Feet.metersPerFoot
	}
}

public extension Kilometers {
	
	public var statuteMiles: StatuteMiles {
		return self * 1000 / Meters.metersPerStatuteMile
	}
}

public extension Hectares {
	
	public var acres: Acres {
		return self / 0.404686
	}
}

public typealias Knots = Double
public typealias MilesPerHour = Double
public typealias MetersPerSecond = Double
public typealias KilometersPerHour = Double

public extension Knots {
	
	public static let metersPerSecondPerKnot = 0.514444
}

public extension KilometersPerHour {
	
	public var metersPerSecond: MetersPerSecond {
		return self / 3.6
	}
	
	public var milesPerHour: MilesPerHour {
		return self * 0.621371
	}
	
	public var knots: Knots {
		return self * 0.539957
	}
}

public enum TemperatureUnits {
	case celcius
	case fahrenheit
}

public typealias Celcius = Double
public typealias Fahrenheit = Double

public extension Celcius {
	
	public var fahrenheit: Fahrenheit {
		return (self * 9.0/5.0) + 32.0
	}
}

public extension Fahrenheit {
	
	public var celcius: Celcius {
		return (self - 32.0) * (5.0/9.0)
	}
}

public typealias HPa = Double
public typealias InHg = Double

public extension HPa {
	
	public var inHg: InHg {
		return self * 0.02953
	}
}

#if os(Linux)
	
	public typealias Coordinate2D = AirMapLocationCoordinate2D
	
	public struct AirMapLocationCoordinate2D {
		
		let latitude: Double
		let longitude: Double
		
		var isValid: Bool {
			return (latitude <= 90 && latitude >= -90) && (longitude <= 180 && longitude >= -180)
		}
	}
	
#else
	
	import CoreLocation
	
	public typealias Coordinate2D = CLLocationCoordinate2D
	
	extension CLLocationCoordinate2D {
		
		public var isValid: Bool {
			return CLLocationCoordinate2DIsValid(self)
		}
	}
	
#endif
