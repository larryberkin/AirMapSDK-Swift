
Pod::Spec.new do |s|
	
	s.name              = 'AirMapSDK'
	s.module_name       = 'AirMap'
	s.author            = 'AirMap, Inc.'
	s.version           = '1.0.2'
	s.summary           = 'AirMap SDK for iOS & macOS'
	s.description       = 'Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.'
	s.license           = { :type => 'Custom', :file => 'LICENSE' }
	s.homepage          = 'https://www.airmap.com/makers/'
	s.documentation_url = 'https://developers.airmap.com/docs/ios-getting-started'
	s.social_media_url  = 'https://twitter.com/AirMapIO'
	s.source = {
		:git => 'https://github.com/AirMap/AirMapSDK-Swift.git',
		:tag => s.version.to_s
	}
	s.cocoapods_version = '>= 1.2.0'
	s.frameworks = 'Foundation'
	
	s.ios.deployment_target = '9.0'
	s.osx.deployment_target = '10.10'
	
	s.default_subspecs = 'Core', 'Traffic', 'Telemetry', 'UI'

	s.subspec 'Core' do |core|
		core.ios.frameworks = 'UIKit'
		core.osx.frameworks = 'AppKit'
		core.source_files = ['Source/Core/**/*.{h,m,swift}', 'Source/Rx/*']
		core.dependency 'Alamofire'
		core.dependency 'ObjectMapper'
		core.dependency 'SimpleKeychain'
		core.dependency 'JWTDecode'
		core.dependency 'RxSwift'
		core.dependency 'RxSwiftExt'
		core.dependency 'RxCocoa'
		core.dependency 'Log'
		core.resources = ['Resources/Core/*.{cer,pdf,xcassets}', 'Resources/Core/Localizations/**/*']
	end
	
	s.subspec 'UI' do |ui|
		ui.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_UI' }
		ui.platform = :ios
		ui.frameworks = 'UIKit'
		ui.dependency 'AirMapSDK/Core'
		ui.dependency 'libPhoneNumber-iOS'
		ui.dependency 'PhoneNumberKit', '1.3.0'
		ui.dependency 'RxDataSources'
		ui.dependency 'Mapbox-iOS-SDK'
		ui.dependency 'Lock', ' 2.3.1'
		ui.dependency 'SwiftSimplify'
		ui.dependency 'SwiftTurf'
		ui.source_files = 'Source/UI/**/{*.swift}'
		ui.resources = ['Resources/UI/*.{xcassets}', 'Resources/UI/Localizations/**/*']
	end
	
	s.subspec 'Traffic' do |traffic|
		traffic.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TRAFFIC' }
		traffic.dependency 'AirMapSDK/Core'
		traffic.dependency 'SwiftMQTT'
		traffic.source_files = 'Source/Traffic/*'
	end
	
	s.subspec 'Telemetry' do |telemetry|
		telemetry.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TELEMETRY' }
		telemetry.dependency 'AirMapSDK/Core'
		telemetry.dependency 'CocoaAsyncSocket', '~> 7.6.0'
		telemetry.dependency 'CryptoSwift'
		telemetry.dependency 'ProtocolBuffers-Swift', '3.0.22'
		telemetry.source_files = 'Source/Telemetry/*'
	end
	
end
