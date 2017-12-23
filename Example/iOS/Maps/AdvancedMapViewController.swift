//
//  AdvancedMapViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 06/27/2016.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import AirMap

/// Example implementation that shows how to configure the map with known rulesets
class AdvancedMapViewController: UIViewController {
	
	// map view is instantiated via the storyboard
	@IBOutlet weak var mapView: AirMapMapView!

	// track all available jurisdictions
	private var jurisdictions: [AirMapJurisdiction] = []

	// track the user's preference for rulesets (preferably by saving to UserDefaults)
	private var preferredRulesetIds: Set<AirMapRulesetId> = []

	// track the active rulesets
	private var activeRulesets: [AirMapRuleset] = [] {
		didSet {
			// update the map with the latest rulesets
			mapView.configuration = .manual(rulesets: activeRulesets)
		}
	}
}

// MARK: - View Lifecycle

extension AdvancedMapViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// register as the map's delegate
		mapView.delegate = self
	}
}

// MARK: - Navigation

extension AdvancedMapViewController {
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		// Handle the segue that displays the rulesets selector
		if segue.identifier == "presentRulesets" {
			
			let nav = segue.destination as! UINavigationController
			let rulesetsVC = nav.viewControllers.first as! RulesetsViewController
			rulesetsVC.availableJurisdictions = jurisdictions
			rulesetsVC.preferredRulesets = activeRulesets
			
			// Set ourselves as the delegate so that we can be notified of ruleset selection
			rulesetsVC.delegate = self
		}

		// Handle the segue that displays the advisories for a given area and rulesets
		if segue.identifier == "presentAdvisories" {
			
			let nav = segue.destination as! UINavigationController
			let advisoriesVC = nav.viewControllers.first as! AdvisoriesViewController
			
			// Construct an AirMapPolygon from the bounding box of the visible area
			advisoriesVC.area = mapView.visibleCoordinateBounds.geometry
			advisoriesVC.rulesets = activeRulesets
		}
	}
}

// MARK: - AirMapMapViewDelegate

extension AdvancedMapViewController: AirMapMapViewDelegate {
	
	func airMapMapViewJurisdictionsDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction]) {
		
		self.jurisdictions = jurisdictions

		// Handle updates to the map's jurisdictions and resolve which rulesets should be active based on user preference
		activeRulesets = AirMapRulesetResolver.resolvedActiveRulesets(with: Array(preferredRulesetIds), from: jurisdictions, enableRecommendedRulesets: false)
	}
	
	func airMapMapViewRegionDidChange(mapView: AirMapMapView, jurisdictions: [AirMapJurisdiction], activeRulesets: [AirMapRuleset]) {
		// opportunity to handle active rulesets changes after the map region changes (used in this example as we are configuring the rulesets manually)
	}
}

// MARK: - RulesetsViewControllerDelegate

extension AdvancedMapViewController: RulesetsViewControllerDelegate {
	
	func rulesetsViewControllerDidSelect(_ rulesets: [AirMapRuleset]) {
		
		let newlySelected = Set(rulesets)
		let previouslySelected = Set(activeRulesets)
		
		let removed = previouslySelected.subtracting(newlySelected)
		let new = newlySelected.subtracting(previouslySelected)
		
		preferredRulesetIds = preferredRulesetIds.subtracting(removed.identifiers).union(new.identifiers)

		// Update the active rulesets with the selected rulesets
		activeRulesets = rulesets
	}
}