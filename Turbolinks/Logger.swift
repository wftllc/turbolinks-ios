//
//  Logger.swift
//  Turbolinks
//
//  Created by Jake Lavenberg on 10/3/18.
//

import Foundation
import os //logging

open class Logger {
	
	static let baseSubsystem: String = "com.goldbelly"
	static let appLog = OSLog(subsystem: baseSubsystem, category: "app")
	static let screenLog = OSLog(subsystem: baseSubsystem, category: "screen")

	static let turbolinksSubsystem: String = "com.goldbelly.turbolinks"
	static let visitableViewLog = OSLog(subsystem: turbolinksSubsystem, category: "visitableView")
	static let visitLog = OSLog(subsystem: turbolinksSubsystem, category: "visit")
	static let jsLog = OSLog(subsystem: turbolinksSubsystem, category: "js")
	static let webviewLog = OSLog(subsystem: turbolinksSubsystem, category: "webview")

	open class func logApp(function: String, message: String = "") {
		let format:StaticString = "%@: %@"
		os_log(format, log: appLog, type: .debug, function, message)
	}
	
	open class func logApp(screen: String, function: String, message: String = "") {
		let format:StaticString = "%@: %@, %@"
		os_log(format, log: screenLog, type: .debug, screen, function, message)
	}
	
	class func log(visitableView: VisitableView, function: String, message: String = "") {
		var isWebViewVisible = false
		var url: String = visitableView.visitable?.visitableURL.absoluteString ?? "<blank>"
		if let webview = visitableView.webView as? WebView, webview.isHidden == .some(false) {
			isWebViewVisible = true
		}
		let isScreenshotVisible = visitableView.isShowingScreenshot
		
		let format:StaticString = "%s, %s: webViewVisible: %s, screenshotVisible: %s; %s"
		os_log(format,
					 log: visitableViewLog,
					 type: .debug,
					 url,
					 function,
					 isWebViewVisible ? "yes" : "no",
					 isScreenshotVisible ? "yes" : "no",
					 message
		)
	}
	
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
