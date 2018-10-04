import WebKit
import UIKit

open class DebugVisitableView: VisitableView {
	private var screenshotTriangleView: UIView!
	private var webviewTriangleView: UIView?

	override func initialize() {
		super.initialize()
		self.addScreenshotFlag()
//		self.addWebviewFlag()
	}
	
	func addWebviewFlag() {
		let triangle = TriangleView(frame: .zero, color: UIColor.red)
		webView?.addSubview(triangle)
		
		webView?.translatesAutoresizingMaskIntoConstraints = false
		screenshotContainerView.addConstraints([
			NSLayoutConstraint(item: triangle, attribute: .top, relatedBy: .equal, toItem: screenshotContainerView, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: triangle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
			NSLayoutConstraint(item: triangle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
			NSLayoutConstraint(item: triangle, attribute: .right, relatedBy: .equal, toItem: screenshotContainerView, attribute: .right, multiplier: 1, constant: 0)
			])
		
		webviewTriangleView = triangle
	}
	
	open override func updateScreenshot() {
		super.updateScreenshot()
		screenshotContainerView.bringSubview(toFront: screenshotTriangleView)
	}
	
	open func addScreenshotFlag() {
		let triangle = TriangleView(frame: .zero, color: UIColor.green)
		screenshotContainerView.addSubview(triangle)
		
		triangle.translatesAutoresizingMaskIntoConstraints = false
		screenshotContainerView.addConstraints([
			NSLayoutConstraint(item: triangle, attribute: .top, relatedBy: .equal, toItem: screenshotContainerView, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: triangle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
			NSLayoutConstraint(item: triangle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
			NSLayoutConstraint(item: triangle, attribute: .right, relatedBy: .equal, toItem: screenshotContainerView, attribute: .right, multiplier: 1, constant: 0)
			])
		
		screenshotTriangleView = triangle
	}

}
open class VisitableView: UIView {
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	func initialize() {
		installHiddenScrollView()
		installActivityIndicatorView()
	}
	
	
	// MARK: Web View
	
	open var webView: WKWebView?
	public var contentInset: UIEdgeInsets? {
		didSet {
			updateContentInsets()
		}
	}
	private weak var visitable: Visitable?
	
	open func activateWebView(_ webView: WKWebView, forVisitable visitable: Visitable) {
		print(#function)
		self.webView = webView
		self.visitable = visitable
		addSubview(webView)
		addFillConstraints(forView: webView)
		installRefreshControl()
		showOrHideWebView()
	}
	
	open func deactivateWebView() {
		print(#function)
		removeRefreshControl()
		webView?.removeFromSuperview()
		webView = nil
		visitable = nil
	}
	
	private func showOrHideWebView() {
		webView?.isHidden = isShowingScreenshot
		print(#function, webView?.isHidden == .some(false) ? "shown" : "hidden")
	}
	
	
	// MARK: Refresh Control
	
	open lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
		return refreshControl
	}()
	
	open var allowsPullToRefresh: Bool = true {
		didSet {
			if allowsPullToRefresh {
				installRefreshControl()
			} else {
				removeRefreshControl()
			}
		}
	}
	
	open var isRefreshing: Bool {
		return refreshControl.isRefreshing
	}
	
	private func installRefreshControl() {
		if let scrollView = webView?.scrollView , allowsPullToRefresh {
			scrollView.addSubview(refreshControl)
		}
	}
	
	private func removeRefreshControl() {
		refreshControl.endRefreshing()
		refreshControl.removeFromSuperview()
	}
	
	@objc func refresh(_ sender: AnyObject) {
		visitable?.visitableViewDidRequestRefresh()
	}
	
	
	// MARK: Activity Indicator
	
	open lazy var activityIndicatorView: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(activityIndicatorStyle: .white)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.color = UIColor.gray
		view.hidesWhenStopped = true
		return view
	}()
	
	private func installActivityIndicatorView() {
		addSubview(activityIndicatorView)
		addFillConstraints(forView: activityIndicatorView)
	}
	
	open func showActivityIndicator() {
		if !isRefreshing {
			activityIndicatorView.startAnimating()
			bringSubview(toFront: activityIndicatorView)
		}
	}
	
	open func hideActivityIndicator() {
		activityIndicatorView.stopAnimating()
	}
	
	
	// MARK: Screenshots
	
	lazy var screenshotContainerView: UIView = {
		let view = UIView(frame: CGRect.zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = self.backgroundColor
		return view
	}()
	
	var screenshotView: UIView?
	
	var isShowingScreenshot: Bool {
		return screenshotContainerView.superview != nil
	}
	
	open func updateScreenshot() {
		guard let webView = self.webView , !isShowingScreenshot, let screenshot = webView.snapshotView(afterScreenUpdates: false) else { return }
		
		screenshotView?.removeFromSuperview()
		screenshot.translatesAutoresizingMaskIntoConstraints = false
		screenshotContainerView.addSubview(screenshot)
		
		screenshotContainerView.addConstraints([
			NSLayoutConstraint(item: screenshot, attribute: .centerX, relatedBy: .equal, toItem: screenshotContainerView, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: screenshot, attribute: .top, relatedBy: .equal, toItem: screenshotContainerView, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: screenshot, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenshot.bounds.size.width),
			NSLayoutConstraint(item: screenshot, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenshot.bounds.size.height)
			])
		
		screenshotView = screenshot
	}
	
	
	open func showScreenshot() {
		print(#function)
		if !isShowingScreenshot && !isRefreshing {
			addSubview(screenshotContainerView)
			addFillConstraints(forView: screenshotContainerView)
			showOrHideWebView()
		}
	}
	
	open func hideScreenshot() {
		print(#function)
		screenshotContainerView.removeFromSuperview()
		showOrHideWebView()
	}
	
	open func clearScreenshot() {
		print(#function)
		screenshotView?.removeFromSuperview()
	}
	
	
	// MARK: Hidden Scroll View
	
	private var hiddenScrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: CGRect.zero)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.scrollsToTop = false
		return scrollView
	}()
	
	private func installHiddenScrollView() {
		insertSubview(hiddenScrollView, at: 0)
		addFillConstraints(forView: hiddenScrollView)
	}
	
	
	// MARK: Layout
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		updateContentInsets()
	}
	
	private func needsUpdateForContentInsets(_ insets: UIEdgeInsets) -> Bool {
		guard let scrollView = webView?.scrollView else { return false }
		return scrollView.contentInset.top != insets.top || scrollView.contentInset.bottom != insets.bottom
	}
	
	private func updateWebViewScrollViewInsets(_ insets: UIEdgeInsets) {
		guard let scrollView = webView?.scrollView, needsUpdateForContentInsets(insets) && !isRefreshing else { return }
		
		scrollView.scrollIndicatorInsets = insets
		scrollView.contentInset = insets
	}
	
	private func updateContentInsets() {
		if #available(iOS 11, *) {
			updateWebViewScrollViewInsets(contentInset ?? hiddenScrollView.adjustedContentInset)
		} else {
			updateWebViewScrollViewInsets(contentInset ?? hiddenScrollView.contentInset)
		}
	}
	
	private func addFillConstraints(forView view: UIView) {
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: [ "view": view ]))
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: [ "view": view ]))
	}
}
