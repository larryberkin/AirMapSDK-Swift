![AirMap: The Airspace Platform for Developers](Resources/Core/AirMap.png)
![Swift 4.0](https://img.shields.io/badge/Swift-4.0-lightgray.svg) [![Version](https://img.shields.io/cocoapods/v/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![License](https://img.shields.io/cocoapods/l/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK) [![Platform](https://img.shields.io/cocoapods/p/AirMapSDK.svg?style=flat)](http://cocoapods.org/pods/AirMapSDK)

Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.

## Requirements

### Environment
* iOS 9.0+, 
* macOS 10.10+, 
* Swift 4.0
* Xcode 9.0+

### Sign up for an [AirMap Developer Account.](https://dashboard.airmap.io/developer/)

 [https://dashboard.airmap.io/developer](https://dashboard.airmap.io/developer)
  
### Read Getting Started Guide
[https://developers.airmap.com/v2.1/docs/getting-started-ios](https://developers.airmap.com/v2.1/docs/getting-started-ios/)

## Contextual Airspace Preview

Contextual Airspace (Rules API, Advisory API, and Flight Plan API) is currently in developer PREVIEW for testing and is subject to change. Contact us for more information.

## Installation

### CocoaPods

Requires CocoaPods 1.3.0+

The AirMap SDK is a CocoaPod written in Swift. CocoaPods is a dependency manager for Cocoa projects. If you don't have CocoaPods, You can install it with the following command:

`$ sudo gem install cocoapods`

### Example Project

***You must have Xcode 9.0+ to run the example.***

To run the example project, run `pod try AirMapSDK`.  This should install the SDK and launch Xcode.

### Integrating into your project

#### CocoaPods

To integrate the AirMap SDK into your Xcode project, navigate to the directory that contains your project and create a new **Podfile** with `pod init` or open an existing one, then add `pod 'AirMapSDK'` to the main target. Make sure to add the line `use_frameworks!`.

```ruby
target 'MyApp' do
  use_frameworks!
  pod 'AirMapSDK', :git => 'https://github.com/airmap/AirMapSDK-Swift', :tag => '2.0.0.rc.3'
end

post_install do |installer|
    # List of Pods to use as Swift 3.2
    myTargets = ['Lock'] 

    installer.pods_project.targets.each do |target|
        if myTargets.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
```

Then, run the following command to install the dependencies:

`$ pod install`

Going forward, open the `MyProject.xcworkspace` file instead of the `MyProject.xcodeproj` file.

Make sure you import the framework before using the SDK.

#### Carthage

The AirMapSDK is also available via Carthage, however, only the Core subspec is currently available

```
github "AirMap/AirMapSDK-Swift" "2.0.0.rc.3"
```

### Importing

```swift
import AirMap
```

## License 

See [LICENSE](https://raw.githubusercontent.com/airmap/AirMapSDK-Swift/master/LICENSE) for details
