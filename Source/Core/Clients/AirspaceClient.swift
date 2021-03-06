//
//  AirspaceClient.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 9/30/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift

internal class AirspaceClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.AirMapApi.airspaceUrl)
	}
	
	func getAirspace(_ airspaceId: AirMapAirspaceId) -> Observable<AirMapAirspace> {
		AirMap.logger.debug("Get Airspace", airspaceId)
		return perform(method: .get, path:"/\(airspaceId)")
	}

	func listAirspace(_ airspaceIds: [AirMapAirspaceId]) -> Observable<[AirMapAirspace]> {
		AirMap.logger.debug("Get Airspace", airspaceIds)
		let params = [
			"ids": airspaceIds.csv
		]
		return perform(method: .get, path:"/list", params: params)
	}

}
