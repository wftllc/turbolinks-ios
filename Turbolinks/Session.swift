import UIKit
import WebKit

public protocol SessionDelegate: class {
	func session(_ session: Session, didProposeVisitToURL URL: URL, withAction action: Action)
	func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError)
	func session(_ session: Session, openExternalURL URL: URL)
	func sessionDidLoadWebView(_ session: Session)
	func sessionDidStartRequest(_ session: Session)
	func sessionDidFinishRequest(_ session: Session)
}

public extension SessionDelegate {
	func sessionDidLoadWebView(_ session: Session) {
		session.webView.navigationDelegate = session
	}
	
	func session(_ session: Session, openExternalURL URL: Foundation.URL) {
		UIApplication.shared.openURL(URL)
	}
	
	func sessionDidStartRequest(_ session: Session) {
	}
	
	func sessionDidFinishRequest(_ session: Session) {
	}
}

open class Session: NSObject {
	open weak var delegate: SessionDelegate?
	
	open var webView: WKWebView {
		return _webView
	}
	
	fileprivate var _webView: WebView
	fileprivate var initialized = false
	fileprivate var refreshing = false
	
	public init(webViewConfiguration: WKWebViewConfiguration) {
		_webView = DebugWebView(configuration: webViewConfiguration)
		super.init()
		_webView.delegate = self
	}
	
	public convenience override init() {
		self.init(webViewConfiguration: WKWebViewConfiguration())
	}
	
	// MARK: Visiting
	
	fileprivate var currentVisit: Visit?
	fileprivate var topmostVisit: Visit?
	
	open var topmostVisitable: Visitable? {
		return topmostVisit?.visitable
	}
	
	open func visit(_ visitable: Visitable) {
		visitVisitable(visitable, action: .Advance)
	}
	
	fileprivate func visitVisitable(_ visitable: Visitable, action: Action) {
		guard visitable.visitableURL != nil else { return }
		
		visitable.visitableDelegate = self
		
		let visit: Visit
		
		if initialized {
			visit = JavaScriptVisit(visitable: visitable, action: action, webView: _webView)
			visit.restorationIdentifier = restorationIdentifierForVisitable(visitable)
		} else {
			visit = ColdBootVisit(visitable: visitable, action: action, webView: _webView)
		}
		
		currentVisit?.cancel()
		currentVisit = visit
		
		visit.delegate = self
		visit.start()
	}
	
	open func reload() {
		if let visitable = topmostVisitable {
			initialized = false
			visit(visitable)
			topmostVisit = currentVisit
		}
	}
	
	// MARK: Visitable activation
	
	fileprivate var activatedVisitable: Visitable?
	
	fileprivate func activateVisitable(_ visitable: Visitable) {
		if visitable !== activatedVisitable {
			if let activatedVisitable = self.activatedVisitable {
				deactivateVisitable(activatedVisitable, showScreenshot: true)
			}
			
			visitable.activateVisitableWebView(webView)
			activatedVisitable = visitable
		}
	}
	
	fileprivate func deactivateVisitable(_ visitable: Visitable, showScreenshot: Bool = false) {
		if visitable === activatedVisitable {
			if showScreenshot {
				visitable.updateVisitableScreenshot()
				visitable.showVisitableScreenshot()
			}
			
			visitable.deactivateVisitableWebView()
			activatedVisitable = nil
		}
	}
	
	// MARK: Visitable restoration identifiers
	
	fileprivate var visitableRestorationIdentifiers = NSMapTable<UIViewController, NSString>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: [])
	
	fileprivate func restorationIdentifierForVisitable(_ visitable: Visitable) -> String? {
		return visitableRestorationIdentifiers.object(forKey: visitable.visitableViewController) as String?
	}
	
	fileprivate func storeRestorationIdentifier(_ restorationIdentifier: String, forVisitable visitable: Visitable) {
		visitableRestorationIdentifiers.setObject(restorationIdentifier as NSString, forKey: visitable.visitableViewController)
	}
	
	fileprivate func completeNavigationForCurrentVisit() {
		if let visit = currentVisit {
			topmostVisit = visit
			visit.completeNavigation()
		}
	}
}

extension Session: VisitDelegate {
	private func logFunctionVisit(function: String, visit: Visit) {
		(visit.webView as? DebugWebView)?.debug(function: function, visit: visit)
	}

	func visitRequestDidStart(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		delegate?.sessionDidStartRequest(self)
	}
	
	func visitRequestDidFinish(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		delegate?.sessionDidFinishRequest(self)
	}
	
	func visit(_ visit: Visit, requestDidFailWithError error: NSError) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit, error)
		delegate?.session(self, didFailRequestForVisitable: visit.visitable, withError: error)
	}
	
	func visitDidInitializeWebView(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		initialized = true
		delegate?.sessionDidLoadWebView(self)
	}
	
	func visitWillStart(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		visit.visitable.showVisitableScreenshot()
		activateVisitable(visit.visitable)
	}
	
	func visitDidStart(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		if !visit.hasCachedSnapshot {
			visit.visitable.showVisitableActivityIndicator()
		}
	}
	
	func visitWillLoadResponse(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		visit.visitable.updateVisitableScreenshot()
		visit.visitable.showVisitableScreenshot()
	}
	
	func visitDidRender(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		visit.visitable.hideVisitableScreenshot()
		visit.visitable.hideVisitableActivityIndicator()
		visit.visitable.visitableDidRender()
	}
	
	func visitDidComplete(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		if let restorationIdentifier = visit.restorationIdentifier {
			storeRestorationIdentifier(restorationIdentifier, forVisitable: visit.visitable)
		}
	}
	
	func visitDidFail(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		visit.visitable.clearVisitableScreenshot()
		visit.visitable.showVisitableScreenshot()
	}
	
	func visitDidFinish(_ visit: Visit) {
		Logger.log(function: #function, visit: visit)
		logFunctionVisit(function: #function, visit: visit)
		print(#function, visit)
		if refreshing {
			refreshing = false
			visit.visitable.visitableDidRefresh()
		}
	}
}

extension Session: VisitableDelegate {
	public func visitableViewWillAppear(_ visitable: Visitable) {
		guard let topmostVisit = self.topmostVisit, let currentVisit = self.currentVisit else { return }
		
		if visitable === topmostVisit.visitable && visitable.visitableViewController.isMovingToParentViewController {
			// Back swipe gesture canceled
			if topmostVisit.state == .completed {
				currentVisit.cancel()
			} else {
				visitVisitable(visitable, action: .Advance)
			}
		} else if visitable === currentVisit.visitable && currentVisit.state == .started {
			// Navigating forward - complete navigation early
			completeNavigationForCurrentVisit()
		} else if visitable !== topmostVisit.visitable {
			// Navigating backward
			visitVisitable(visitable, action: .Restore)
		}
	}
	
	public func visitableViewDidAppear(_ visitable: Visitable) {
		if let currentVisit = self.currentVisit , visitable === currentVisit.visitable {
			// Appearing after successful navigation
			completeNavigationForCurrentVisit()
			if currentVisit.state != .failed {
				activateVisitable(visitable)
			}
		} else if let topmostVisit = self.topmostVisit , visitable === topmostVisit.visitable && topmostVisit.state == .completed {
			// Reappearing after canceled navigation
			visitable.hideVisitableScreenshot()
			visitable.hideVisitableActivityIndicator()
			activateVisitable(visitable)
		}
	}
	
	public func visitableDidRequestReload(_ visitable: Visitable) {
		if visitable === topmostVisitable {
			reload()
		}
	}
	
	public func visitableDidRequestRefresh(_ visitable: Visitable) {
		if visitable === topmostVisitable {
			refreshing = true
			visitable.visitableWillRefresh()
			reload()
		}
	}
}

extension Session: WebViewDelegate {
	func webView(_ webView: WebView, didProposeVisitToLocation location: URL, withAction action: Action) {
		delegate?.session(self, didProposeVisitToURL: location, withAction: action)
	}
	
	func webViewDidInvalidatePage(_ webView: WebView) {
		if let visitable = topmostVisitable {
			visitable.updateVisitableScreenshot()
			visitable.showVisitableScreenshot()
			visitable.showVisitableActivityIndicator()
			reload()
		}
	}
	
	func webView(_ webView: WebView, didFailJavaScriptEvaluationWithError error: NSError) {
		if let currentVisit = self.currentVisit , initialized {
			initialized = false
			currentVisit.cancel()
			visit(currentVisit.visitable)
		}
	}
}

extension Session: WKNavigationDelegate {
	
	#warning("CHECK THIS: returns () instead of Void")
	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> ()) {
		Logger.logWebView(function: "Session.decidePolicyFor", currentVisit: self.currentVisit, message: navigationAction.request.url?.absoluteString ?? "")
		let navigationDecision = NavigationDecision(navigationAction: navigationAction)
		decisionHandler(navigationDecision.policy)
		
		if let URL = navigationDecision.externallyOpenableURL {
			openExternalURL(URL)
		} else if navigationDecision.shouldReloadPage {
			reload()
		}
	}

	
	public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		Logger.logWebView(function: "Session.didCommit", currentVisit: self.currentVisit, message: navigation.debugDescription)
	}

	public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		Logger.logWebView(function: "Session.didStartProvisionalNavigation", currentVisit: self.currentVisit, message: navigation.debugDescription)
	}
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		Logger.logWebView(function: "didFinish", currentVisit: self.currentVisit, message: navigation.debugDescription)
	}
	
	public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
		Logger.logWebView(function: "Session.webViewWebContentProcessDidTerminate", currentVisit: self.currentVisit)
	}
	
	fileprivate struct NavigationDecision {
		let navigationAction: WKNavigationAction
		
		var policy: WKNavigationActionPolicy {
			return navigationAction.navigationType == .linkActivated || isMainFrameNavigation ? .cancel : .allow
		}
		
		var externallyOpenableURL: URL? {
			if let URL = navigationAction.request.url , shouldOpenURLExternally {
				return URL
			} else {
				return nil
			}
		}
		
		var shouldOpenURLExternally: Bool {
			let type = navigationAction.navigationType
			return type == .linkActivated || (isMainFrameNavigation && type == .other)
		}
		
		var shouldReloadPage: Bool {
			let type = navigationAction.navigationType
			return isMainFrameNavigation && type == .reload
		}
		
		var isMainFrameNavigation: Bool {
			return navigationAction.targetFrame?.isMainFrame ?? false
		}
	}
	
	fileprivate func openExternalURL(_ URL: Foundation.URL) {
		delegate?.session(self, openExternalURL: URL)
	}
}
