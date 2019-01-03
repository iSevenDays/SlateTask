//
//  WifiInfo.swift
//  SlateTask
//
//  Created by Anton Sokolchenko on 1/3/19.
//  Copyright © 2019 Sokolchenko. All rights reserved.
//

import Foundation

import SystemConfiguration.CaptiveNetwork

// To use this on iOS 12
// We need to add Wi-Fi capability https://stackoverflow.com/questions/50767946/systemconfiguration-captivenetwork-doesnt-work-on-ios-12
// Unfortunately, my Apple ID doesn't support this
class WiFiInfo {
	class var networkName: String {
		var currentSSID = ""
		if let interfaces = CNCopySupportedInterfaces() {
			for i in 0..<CFArrayGetCount(interfaces) {
				let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
				let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
				let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
				if let unsafeInterfaceData = unsafeInterfaceData {
					let interfaceData = unsafeInterfaceData as Dictionary
					if let ssid = interfaceData["SSID" as NSString] as? String {
						currentSSID = ssid
					}
				}
			}
		}
		return currentSSID
	}
}
