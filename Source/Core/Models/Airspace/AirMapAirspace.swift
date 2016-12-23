//
//  AirMap+Airspace.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/29/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

public class AirMapAirspace: NSObject {
	
	public var id: String!
	public var name: String!
	public var type: AirMapAirspaceType!
	public var country: String!
	public var state: String!
	public var city: String!
	public var geometry: AirMapGeometry!
	public var propertyBoundary: AirMapGeometry!
	public var rules = [AirMapAirspaceRule]()
	
	public required init?(_ map: Map) {}
	
	override public var hashValue:Int {
		return id.hashValue
	}
	
	public override func isEqual(object: AnyObject?) -> Bool {
		if let object = object as? AirMapAirspace {
			return object.id == self.id
		} else {
			return false
		}
	}
}

extension AirMapAirspace: Mappable {
	
	public func mapping(map: Map) {
		id               <-  map["id"]
		name             <-  map["name"]
		country          <-  map["country"]
		state            <-  map["state"]
		city             <-  map["city"]
		geometry         <- (map["geometry"], GeoJSONToAirMapGeometryTransform())
		rules            <-  map["rules"]
		propertyBoundary <- (map["related_geometry.property_boundary.geometry"], GeoJSONToAirMapGeometryTransform())
		
		var type: String?
		type        <- map["type"]
		if let type = type {
			self.type = AirMapAirspaceType.airspaceTypeFromName(type)
		}
	}
	
}

public func ==(lhs: AirMapAirspace, rhs: AirMapAirspace) -> Bool {
	return lhs.id == rhs.id
}
