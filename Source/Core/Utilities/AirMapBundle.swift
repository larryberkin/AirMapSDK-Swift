//
//  AirMapBundle.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 6/10/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation

public class AirMapBundle {
	
	public class var core: Bundle {
        
		return Bundle(for: AirMap.self)
	}

	public class var ui: Bundle {
		
		return Bundle(for: AirMap.self)
	}
	
}
