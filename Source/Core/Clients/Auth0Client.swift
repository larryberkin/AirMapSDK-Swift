//
//  AuthClient.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 8/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit.UIDevice
#endif

import Foundation
import RxSwift

internal class Auth0Client: HTTPClient {

	init() {
		super.init(basePath: "https://" + AirMap.configuration.auth0Host)
	}

	func refreshAccessToken() -> Observable<AirMapToken> {
		AirMap.logger.debug("Refresh Access Token")

		guard let refreshToken = AirMap.authSession.getRefreshToken() else {
			return Observable.error(AirMapError.unauthorized)
		}

		var params = [String: Any]()
		params["grant_type"] = Constants.AirMapApi.Auth.grantType
		params["client_id"] = AirMap.configuration.auth0ClientId
		params["api_type"] = "app"
		params["refresh_token"] = refreshToken
		params["scope"] = "openid offline_access email"

		return perform(method: .post, path:"/delegation", params: params, keyPath: nil)
			.do(onNext: { token in
				AirMap.authToken = token.authToken
			}, onError: { error in
				AirMap.logger.debug("ERROR: \(error)")
			})
    }
	
    func startPasswordlessLogin(with phoneNumber: String) -> Observable<Void> {
		
		var params = [String: Any]()
		params["phone_number"] = phoneNumber
		params["client_id"] = AirMap.configuration.auth0ClientId
		params["connection"] = "sms"
		params["send"] = "code"
		
        return perform(method: .post, path:"/passwordless/start", params: params, keyPath: nil)
    }
    
    func verifyPasswordlessLogin(with phoneNumber: String, code: String) -> Observable<Auth0Credentials> {
		
		let deviceId: String
		
		#if os(iOS) || os(tvOS)
            deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        #elseif os(OSX)
            deviceId = "macOS-" + UUID().uuidString
		#endif
		
		var params = [String: Any]()
		params["username"] = phoneNumber
		params["password"] = code
		params["client_id"] = AirMap.configuration.auth0ClientId
		params["connection"] = "sms"
		params["grant_type"] = "password"
		params["device"] = deviceId
		params["scope"] = Constants.AirMapApi.Auth.scope
        
        return perform(method: .post, path:"/oauth/ro", params: params, keyPath: nil)
            .do(onNext: { credentials in
                AirMap.authSession.authToken = credentials.idToken
                AirMap.authSession.refreshToken = credentials.refreshToken
            }, onError: { error in
                AirMap.logger.debug("ERROR: \(error)")
            })
    }
    
}
