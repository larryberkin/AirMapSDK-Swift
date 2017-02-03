//
//  AirMapPilotProfileViewController.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/21/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import libPhoneNumber_iOS

open class AirMapPilotProfileField {
	
	public enum FieldType {
		case text
		case email
		case phoneNumber
		
		var type: String {
			switch self {
			case .text: return "text"
			case .email: return "email"
			case .phoneNumber: return "phone"
			}
		}
	}
	
	let label: String
	let key: String
	
	internal let rx_value = PublishSubject<String?>()
	
	open var type: FieldType = .text
	
	public init(label: String, key: String, type: FieldType = .text) {
		self.label = label
		self.type = type
		self.key = key
	}
}


class AirMapFormTextField: UITableViewCell {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var label: UILabel!
}

class AirMapPilotProfileViewController: UITableViewController, AnalyticsTrackable {
	
	var screenName = "Pilot Profile"
	
	var customFields = [AirMapPilotProfileField]()

	var pilot: Variable<AirMapPilot?>!
	
	@IBOutlet weak var fullName: UILabel!
	@IBOutlet weak var statisticsLabel: UILabel!
	@IBOutlet var saveButton: UIButton!
	
	fileprivate typealias Model = SectionModel<String,AirMapPilotProfileField>
	fileprivate let dataSource = RxTableViewSectionedReloadDataSource<Model>()
	fileprivate let activityIndicator = ActivityIndicator()
	fileprivate let disposeBag = DisposeBag()
	
	enum Section: Int {
		case pilotInfo
		case customInfo
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = nil
		tableView.delegate = nil
		
		let faaReg = AirMapPilotProfileField(label: "FAA Registration Number", key: "faa_registration_number")
		customFields.append(faaReg)

		setupBindings()
		setupTableView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard pilot.value == nil else { return }
		
		AirMap.rx.getAuthenticatedPilot().asOptional()
			.trackActivity(activityIndicator)
			.bindTo(pilot)
			.addDisposableTo(disposeBag)
		
		trackView()
	}
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
	override var inputAccessoryView: UIView? {
		return saveButton
	}
	
	fileprivate func sectionModel(_ pilot: AirMapPilot) -> [Model] {
		
		let firstNameField = AirMapPilotProfileField(label: "First Name", key: "firstName")
		let lastNameField  = AirMapPilotProfileField(label: "Last Name", key: "lastName")
		let usernameField  = AirMapPilotProfileField(label: "Username", key: "username")
		let emailField     = AirMapPilotProfileField(label: "Email", key: "email", type: .email)
		let phoneField     = AirMapPilotProfileField(label: "Phone Number", key: "phone", type: .phoneNumber)
		
		let pilotFields = [firstNameField, lastNameField, usernameField, emailField, phoneField]
		
		pilotFields.forEach { field in
			
			field.rx_value.skip(1).asDriver(onErrorJustReturn: nil)
				.drive(onNext: { text in
					switch field.key {
					case "firstName":
						pilot.firstName = text
					case "lastName":
						pilot.lastName = text
					case "username":
						pilot.username = text
					case "email":
						pilot.email = text
					case "phone":
						pilot.phone = text
					default:
						assertionFailure()
					}
				})
				.addDisposableTo(disposeBag)
		}
		
		customFields.forEach { customField in

			customField.rx_value.skip(1).asDriver(onErrorJustReturn: nil)
				.drive(onNext: { text in pilot.setAppMetadata(value: text, forKey: customField.key) })
				.addDisposableTo(disposeBag)
		}
		
		Driver
			.combineLatest([firstNameField.rx_value.asDriver(onErrorJustReturn: nil), lastNameField.rx_value.asDriver(onErrorJustReturn: nil)], fullNameString)
			.drive(fullName.rx.text)
			.addDisposableTo(disposeBag)
		
		return [
			Model(model: "Personal Info", items: pilotFields),
			Model(model: "Additional Info", items: customFields)
		]
	}
	
	fileprivate func setupTableView() {
		
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension

		dataSource.configureCell = { [unowned self] dataSource, tableView, indexPath, field in
			let cell: AirMapFormTextField
			
			let cellIdentifier: String
			switch field.type  {
			case .text:
				cellIdentifier = "TextCell"
			case .email:
				cellIdentifier = "EmailCell"
			case .phoneNumber:
				cellIdentifier = "PhoneCell"
			}
			
			cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AirMapFormTextField
			cell.label.text = field.label

			let pilot = self.pilot.value
			
			switch Section(rawValue: indexPath.section)! {
				
			case .pilotInfo:
				
				var value: String?
				switch field.key {
				case "firstName":
					value = pilot?.firstName
				case "lastName":
					value = pilot?.lastName
				case "username":
					value = pilot?.username
				case "email":
					value = pilot?.email
				case "phone":
					value = pilot?.phone
				default:
					assertionFailure()
				}

				if let value = value {
					cell.textField.rx.text.onNext(value)
				}
				
			case .customInfo:
				if let value = pilot?.appMetadata()[field.key] as? String {
					cell.textField.rx.text.onNext(value)
				}
			}

			cell.textField.rx.text
				.bindTo(field.rx_value)
				.addDisposableTo(self.disposeBag)
			
			return cell
		}

		dataSource.titleForHeaderInSection = { dataSource, index in
			dataSource.sectionModels[index].model
		}
	}
	
	fileprivate func setupBindings() {
		
		pilot.asObservable()
			.unwrap()
			.map(sectionModel)
			.observeOn(MainScheduler.instance)
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.addDisposableTo(disposeBag)
		
		pilot.asObservable()
			.unwrap()
			.observeOn(MainScheduler.instance)
			.subscribeNext(weak: self, AirMapPilotProfileViewController.configureStats)
			.addDisposableTo(disposeBag)
		
		activityIndicator.asObservable()
			.throttle(0.25, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bindTo(rx_loading)
			.addDisposableTo(disposeBag)
	}
	
	@IBAction func savePilot() {
		
		trackEvent(.tap, label: "Save")

		guard let pilot = pilot.value else { return }

		AirMap.rx.updatePilot(pilot)
			.trackActivity(activityIndicator)
			.do(onError: { error in
				self.trackEvent(.save, label: "Error", value: NSNumber(value: (error as NSError).code))
			}, onCompleted: { [unowned self] in
				self.view.endEditing(true)
				self.dismiss(animated: true, completion: nil)
				self.trackEvent(.save, label: "Success")
			})
			.subscribe()
			.addDisposableTo(disposeBag)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "modalUpdatePhoneNumber" {
			let nav = segue.destination as! AirMapPhoneVerificationNavController
			nav.phoneVerificationDelegate = self
			let phoneVC = nav.viewControllers.first as! AirMapPhoneVerificationViewController
			phoneVC.pilot = pilot.value
		}
	}
	
	fileprivate func fullNameString(_ names: [String?]) -> String {
		return names.flatMap { $0 }.joined(separator: " ").uppercased()
	}
	
	fileprivate func configureStats(_ pilot: AirMapPilot) {
		statisticsLabel.text = "\(pilot.statistics.totalAircraft) Aircraft, \(pilot.statistics.totalFlights) Flights"
	}
	
	@IBAction func unwindToPilotProfile(_ segue: UIStoryboardSegue) { /* Interface Builder hook; keep */ }

}

extension AirMapPilotProfileViewController: AirMapPhoneVerificationDelegate {
	
	func phoneVerificationDidVerifyPhoneNumber() {
		dismiss(animated: true, completion: nil)
	}
}
