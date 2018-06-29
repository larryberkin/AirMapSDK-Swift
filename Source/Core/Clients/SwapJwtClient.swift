//
//  SwapJwtClient
//  AirMap
//
//  Created by Michael Odere on 6/21/18.
//  Copyright © 2018 AirMap, Inc. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

internal class SwapJwtClient: HTTPClient {
	
	init() {
		super.init(basePath: Constants.AirMapApi.Auth.tokenSwap)
	}
	
	func performSwap(jwt: String) -> Observable<AirMapSwapJwt> {
		let params = ["jwt": jwt]
		
		return perform(method: .post, path: "/delegation", params: params, keyPath: nil)
			.do(onNext: { token in
			}, onError: { error in
				AirMap.logger.debug("ERROR:", error)
			})
	}
}
