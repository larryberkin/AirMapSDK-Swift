//
//  AirMapJurisdiction.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 3/24/17.
//  Copyright © 2017 AirMap, Inc. All rights reserved.
//

/// An entity that has jurisdiction for generating rulesets for a given area
public struct AirMapJurisdiction {
	
	/// The unique identifier for the jurisdiction
	public let id: Int

	/// The name of the jurisdiction
	public let name: String
	
	/// The jurisdiction's region type
	public let region: Region

	/// A list rulesets available under this jurisdiction
	public let ruleSets: [AirMapRuleSet]
	
	/// An enumeration of the region types
	public enum Region: String {
		case federal
        case federalBackup = "federal backup"
        case federalStructureBackup = "federal structure backup"
		case state
		case county
		case city
		case local
	}
	
	/// A filtered list of all the required rulesets
	public var requiredRuleSets: [AirMapRuleSet] {
		return ruleSets.filter { $0.type == .required }
	}
	
	/// A filtered list of all pick-one rulesets
	public var pickOneRuleSets: [AirMapRuleSet] {
		return ruleSets.filter { $0.type == .pickOne }
	}
	
	/// The default pick-one ruleset for the jurisdiction
	public var defaultPickOneRuleSet: AirMapRuleSet? {
		return pickOneRuleSets.first(where: { $0.isDefault }) ?? pickOneRuleSets.first
	}
	
	/// A filtered list of all optional rulesets
	public var optionalRuleSets: [AirMapRuleSet] {
		return ruleSets.filter { $0.type == .optional }
	}
	
	/// A list of AirMap-recommended rulesets for the jurisdiction
	public var airMapRecommendedRuleSets: [AirMapRuleSet] {
		return ruleSets.filter { $0.shortName.uppercased() == "AIRMAP" }
	}
}

extension AirMapJurisdiction.Region {
	
	var order: Int {
		return [.federal, .federal, .federalStructureBackup, .state, .county, .city, .local].index(of: self)!
	}
}

extension AirMapJurisdiction: Hashable, Equatable, Comparable {
	
	public static func ==(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	public static func <(lhs: AirMapJurisdiction, rhs: AirMapJurisdiction) -> Bool {
		return lhs.region.order < rhs.region.order
	}
	
	public var hashValue: Int {
		return id.hashValue
	}
}

// MARK: - JSON Serialization

import ObjectMapper

extension AirMapJurisdiction: ImmutableMappable {
	
	public init(map: Map) throws {
		
		do {
			id     = try map.value("id")
			name   = try map.value("name")
			region = try map.value("region")
			
			guard let ruleSetJSON = map.JSON["rulesets"] as? [[String: Any]] else {
				throw AirMapError.serialization(.invalidJson)
			}
			
			// Patch the JSON with information about the jurisdiction :/
			var updatedJSON = [[String: Any]]()
			for var json in ruleSetJSON {
				json["jurisdiction"] = ["id": id, "name": name, "region": region.rawValue]
				updatedJSON.append(json)
			}
			
			let mapper = Mapper<AirMapRuleSet>(context: AirMapRuleSet.Origin.tileService)
			ruleSets = try mapper.mapArray(JSONArray: updatedJSON)
		}
		catch let error {
			AirMap.logger.error(error)
			throw error
		}
	}
}