//
//  Config.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 6/24/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

struct Config {

	struct AirMapApi {

		static let host = "https://api.airmap.com"

		static var advisoryUrl: String {
			return AirMapApi.urlForResource("advisory", version: "v1")
		}
		static var aircraftUrl: String {
            return AirMapApi.urlForResource("aircraft", version: "v2")
		}
		static var airspaceUrl: String {
			return AirMapApi.urlForResource("airspace", version: "v2")
		}
		static var flightUrl: String {
            return AirMapApi.urlForResource("flight", version: "v2")
		}
		static var permitUrl: String {
			return AirMapApi.urlForResource("permit", version: "v2")
		}
		static var pilotUrl: String {
			return AirMapApi.urlForResource("pilot", version: "v2")
		}
        static var authUrl: String {
            return AirMapApi.urlForResource("auth", version: "v1")
        }
		static var statusUrl: String {
			return AirMapApi.urlForResource("status", version: "v2")
		}
		static var ruleUrl: String {
			return AirMapApi.urlForResource("rules", version: "v1")
		}
		static var mapTilesUrl: String {
			return AirMapApi.urlForResource("maps", version: "v4") + "/tilejson"
		}
		static var mapSourceUrl: String {
			return AirMapApi.urlForResource("tiledata", version: "v1")
		}
		static func urlForResource(_ named: String, version: String) -> String {
			if let env = AirMap.configuration.environment {
				if env == "stage" && named == "status" && version == "alpha" {
					return "\(host)/\(named)/alpha/stage"
				}
			}
			return "\(host)/\(named)/" + (AirMap.configuration.environment ?? "\(version)")
		}
		
		static let mapStyleVersion = "0.7.3"
		static var mapStylePath: String {
			let env = AirMap.configuration.environment ?? "prod"
			if env == "prod" {
				return "https://cdn.airmap.com/static/map-styles/\(mapStyleVersion)/"
			} else {
				return "https://cdn.airmap.com/static/map-styles/\(env)/\(mapStyleVersion)/"
			}
		}
		
		struct Auth {
			static let ssoDomain = "sso.airmap.io"
			static let scope     = "openid+offline_access"
			static let grantType = "urn:ietf:params:oauth:grant-type:jwt-bearer"
			static let keychainKeyRefreshToken = "com.airmap.airmapsdk.refresh_token"
		}
		
		// Used only for API date formatting
		static let dateFormat  = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Ex: 2016-06-30T16:54:17.606Z
		static let smsCodeLength = 6
	}

	struct AirMapTelemetry {
		static var host: String {
            if let env = AirMap.configuration.environment {
                if env == "stage" { return "api-udp-telemetry.\(env).airmap.com" }
            }
	        return "api-udp-telemetry.airmap.com"
		}
		
        static let port = UInt16(16060)
		
		struct SampleFrequency {
			static let position: TimeInterval = 1/5
			static let attitude: TimeInterval = 1/5
			static let speed: TimeInterval = 1/5
			static let barometer: TimeInterval = 5
		}
	}

	struct AirMapTraffic {
		static var host: String {
			let env = AirMap.configuration.environment ?? "prod"
			return "mqtt-\(env).airmap.io"
		}
		static let port = UInt16(8883)
		static let keepAlive = UInt16(15)
		static let expirationInterval = TimeInterval(30)
		static let trafficAlertChannel = "uav/traffic/alert/"
		static let trafficSituationalAwarenessChannel = "uav/traffic/sa/"
		#if os(OSX)
		static let clientId = UUID().uuidString
		#else
		static let clientId = UIDevice.current.identifierForVendor!.uuidString
		#endif
	}

	struct Maps {
		static let pointsPerCirclePolygon = CGFloat(90)
		static let bufferSliderLinearity: Double = 2
		static let minimumRadius: Meters = 10
		static let maximumRadius: Meters = 1_000
		static let feetPerMeters: Feet = 3.2808
		static let tileMinimumZoomLevel = 7
		static let tileMaximumZoomLevel = 12
		static let futureTemporalWindow: TimeInterval = 4*60*60
	}
	
}
