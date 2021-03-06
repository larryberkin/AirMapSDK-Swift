//
//  AirMapFlightAircraftCell.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/18/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AirMapFlightAircraftCell: UITableViewCell, Dequeueable {
	
	static let reuseIdentifier = String(describing: AirMapFlightAircraftCell.self)
	
	@IBOutlet weak var selectedAircraft: UILabel!

	let aircraft = Variable(nil as AirMapAircraft?)
	fileprivate let disposeBag = DisposeBag()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupBindings()
	}
	
	fileprivate func setupBindings() {
		
		aircraft
			.asObservable()
			.subscribeOn(MainScheduler.instance)
			.map {
				let selectAircraftTitle = LocalizedStrings.Aircraft.selectAircraft
				return $0?.nickname ?? selectAircraftTitle
			}
			.bind(to: selectedAircraft.rx.text)
			.disposed(by: disposeBag)
	}
}
