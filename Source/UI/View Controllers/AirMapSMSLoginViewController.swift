//
//  AirMapSMSLoginViewController.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 3/3/17.
//
//

import UIKit
import RxSwift
import RxCocoa
import PhoneNumberKit

@available(*, unavailable)
class AirMapSMSLoginViewController: UITableViewController, AnalyticsTrackable, AirMapPhoneCountrySelectorDelegate {
    
    // MARK: - Properties
    var screenName = "SMS Login"
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var phone: PhoneNumberTextField!
    
    fileprivate let phoneNumberKit = PhoneNumberKit()
    fileprivate var regionCode: String!
    fileprivate let activityTracker = ActivityTracker()
    
    fileprivate var phoneNumber: PhoneNumber? {
        guard let phone =  phone.text, let region = regionCode else { return nil }
        return try? phoneNumberKit.parse(phone, withRegion: region, ignoreType: false)
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDefaultCountryCode()
        setupPhoneNumberField()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        validateForm()
        trackView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        phone.becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return submitButton
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    fileprivate enum Segue: String {
        case pushCountrySelector
        case pushLoginCode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch Segue(rawValue: identifier)! {
            
        case .pushCountrySelector:
            trackEvent(.tap, label: "Select Country")
            let countryVC = segue.destination as! AirMapPhoneCountryViewController
            countryVC.selectionDelegate = self
            countryVC.selectedCountryIdentifier = regionCode
            
        case .pushLoginCode:
            let loginWithCodeVC = segue.destination as! AirMapLoginWithCodeViewController
            
            if let phoneNumber = phoneNumber {
                loginWithCodeVC.phoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            }
            
            break
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupBindings() {
        
        phone.rx.text.asObservable()
            .map { [unowned self] _ in
                self.phone.isValidNumber
            }
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        activityTracker.asObservable()
            .throttle(0.25, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: rx_loading)
            .disposed(by: disposeBag)
    }
    
    fileprivate func setupDefaultCountryCode() {
        regionCode = Locale.current.regionCode ?? "US"
        country.text = Locale.current.localizedString(forRegionCode: regionCode) ?? "United States"
        phone?.defaultRegion = regionCode
    }
    
    fileprivate func setupPhoneNumberField() {
        
        phone?.defaultRegion = regionCode
    }
    
    // MARK: - Instance Methods
    
    @IBAction func submitForm() {
        
//        guard let phoneNumber = phoneNumber else { return }
		
//        trackEvent(.tap, label: "Save Button")
		
//        AirMap.rx.performPhoneNumberLogin(phoneNumber: phoneNumberKit.format(phoneNumber, toType: .e164))
//            .trackActivity(self.activityIndicator)
//            .do(
//                onError: { [unowned self] error in
//                    self.trackEvent(.save, label: "error", value: NSNumber(value: (error as NSError).code))
//                },
//                onCompleted: { [unowned self] _ in
//                    self.trackEvent(.save, label: "Success")
//                }
//            )
//            .subscribeNext(weak: self, AirMapSMSLoginViewController.verifySMSToken)
//            .disposed(by: disposeBag)
		
    }
    
    fileprivate func validateForm() {
        submitButton?.isEnabled = phone.isValidNumber
    }
    
    fileprivate func verifySMSToken() {
        performSegue(withIdentifier: Segue.pushLoginCode.rawValue, sender: self)
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
	
	func phoneCountrySelectorDidSelect(country name: String, country code: String) {
		if regionCode != code { phone.text = PartialFormatter().formatPartial(phone.text ?? "") }
		
		regionCode = code
		country.text = name
		setupPhoneNumberField()
		_ = navigationController?.popViewController(animated: true)
	}
	
	func phoneCountrySelectorDidCancel() {
		_ = navigationController?.popViewController(animated: true)
	}
}

