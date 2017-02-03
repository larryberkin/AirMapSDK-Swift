//
//  AirMapPilot.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/13/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import ObjectMapper

open class AirMapPilot {

	open var pilotId: String!
	open var email: String!
	open var firstName: String?
	open var lastName: String?
	open var username: String?
	open var pictureUrl: String!
	open var phone: String?
	open var phoneVerified: Bool = false
	open var emailVerified: Bool = false
	open var statistics: AirMapPilotStats!

	fileprivate var _userMetadata = [String: Any]()
	fileprivate var _appMetadata = [String: Any]()
	
	open func appMetadata() -> [String: Any] {
		return _appMetadata
	}
	
	open func setAppMetadata(value: Any?, forKey: String) {
		_appMetadata[forKey] = value
	}

	internal init() {}
	public required init?(map: Map) {}
}

extension AirMapPilot: Mappable {
	
	public func mapping(map: Map) {
		pilotId        <-  map["id"]
		email          <-  map["email"]
		firstName      <-  map["first_name"]
		lastName       <-  map["last_name"]
		phone          <-  map["phone"]
		pictureUrl     <-  map["picture_url"]
		username       <-  map["username"]
		phoneVerified  <-  map["verification_status.phone"]
		emailVerified  <-  map["verification_status.email"]
		_userMetadata  <-  map["user_metadata"]
		_appMetadata   <-  map["app_metadata"]
		statistics     <-  map["statistics"]
	}

	internal func params() -> [String: Any] {

		return [
			"first_name":     firstName,
			"last_name":      lastName,
			"user_metadata":  _userMetadata,
			"app_metadata":   _appMetadata,
			"username":       username,
			"phone":          phone,
		]
	}

}
