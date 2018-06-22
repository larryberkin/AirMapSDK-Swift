//
//  AirMap+Auth.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 7/22/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

// MARK: - Auth Delegate

/// Protocol for handling AirMap authentication state changes
public protocol AirMapAuthSessionDelegate: class {
	func airmapSessionShouldAuthenticate()
	func airMapAuthSessionDidAuthenticate(_ pilot: AirMapPilot)
	func airMapAuthSessionAuthenticationDidFail(_ error: Error)
}

extension AirMap {
	
	// MARK: - Auth

	/// A JWT auth token that identifies the logged in user accessing the service. Required for all authenticated endpoints.
	public static var authToken: String? {
		didSet { authSession.authToken = authToken }
	}

	/// Setting the auth session delegate automatically calls the delegate whenever a pilot authenticated, fails to
	/// authenticate or needs to re-authenticate after a token expiration
	public static var authSessionDelegate: AirMapAuthSessionDelegate? {
		didSet { authSession.delegate = authSessionDelegate }
	}

	/// Refresh the auth token. Also notifies the `AirMapAuthSessionDelegate` upon completion
	///
	/// - Parameter completion: A completion handler to call with the Result
	public static func refreshAuthToken(_ completion: @escaping (Result<AirMapToken>) -> Void) {
		rx.refreshAuthToken().thenSubscribe(completion)
	}
    
    /// Authenticates an Anonymous User associated with the Developer API Key and returns an AuthToken.
    ///
    /// - Parameters:
    ///   - userId: a third-party user id
    ///   - completion: A completion handler to call with the Result
    public static func performAnonymousLogin(userId: AirMapPilotId, completion: @escaping (Result<AirMapToken>) -> Void) {
        rx.performAnonymousLogin(userId: userId).thenSubscribe(completion)
    }
	
	/// Initiates passwordless authentication by sending the provided phone number a verification code via SMS
	///
	/// - Parameters:
	///   - phoneNumber: The phone number to send the verification code to
	///   - completion: A completion handler to call with the Result
	public static func startPasswordlessLogin(with phoneNumber: String, completion: @escaping (Result<Void>) -> Void) {
        auth0Client.startPasswordlessLogin(with: phoneNumber).thenSubscribe(completion)
    }
    
	/// Completes passwordless login by verifying the phone number and verification code
	///
	/// - Parameters:
	///   - phoneNumber: The phone number to use for authentication
	///   - code: The SMS verification code that was received
	///   - completion: A completion handler to call with the Result
	public static func verifyPasswordlessLogin(with phoneNumber: String, code: String, completion: @escaping (Result<Auth0Credentials>) -> Void) {
        auth0Client.verifyPasswordlessLogin(with: phoneNumber, code: code).thenSubscribe(completion)
    }

	/// Swaps an AirMap jwt for a jwt usable with third parties
	///
	/// - Parameters:
	///   - jwt: Current users jwt token
	public static func swapToken(with jwt: String, completion: @escaping (Result<AirMapSwapToken>) -> Void) {
		swapTokenClient.performSwap(jwt: jwt).thenSubscribe(completion)
	}

    /// Log out the currently authenticated pilot
    public static func logout() {
        authToken = nil
	}
}
