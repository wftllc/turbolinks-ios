//
//  Logger.swift
//  Turbolinks
//
//  Created by Jake Lavenberg on 10/3/18.
//

import Foundation
import os //logging

class Logger {
	
	static let subsystem: String = "com.goldbelly.turbolinks"
	static let visitLog = OSLog(subsystem: subsystem, category: "visit")
	static let jsLog = OSLog(subsystem: subsystem, category: "js")
	static let webviewLog = OSLog(subsystem: subsystem, category: "webview")

	class func logWebView(function: String, currentVisit: Visit?, message: String = "") {
		let format:StaticString = "%s: %s, %s"
		let visitState = currentVisit?.state ?? VisitState.initialized
		os_log(format, log: webviewLog, type: .debug, function, String(describing: visitState), message)
	}

	class func log(function: String, visit: Visit) {
		let format:StaticString = "%@: %@"
		os_log(format, log: visitLog, type: .debug, function, visit.debugDescription)
	}
	
	class func logJS(callFunction function: String, identifier: String) {
		os_log("call: %s, %s", log: jsLog, type: .debug, function, identifier)
	}

	class func logJS(receivedMessage message: ScriptMessage) {
		os_log("message: %s, %s, %s, %s, %S", log: jsLog, type: .debug, message.name.rawValue, message.identifier ?? "", (message.location?.absoluteString ?? ""), message.action?.rawValue ?? "")
	}
}
