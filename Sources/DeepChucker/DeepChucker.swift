import Foundation
import UIKit
import SwiftUI

public class DeepChucker: NSObject {
    /// Hosts that will be ignored from being recorded
    @objc public static var ignoredHosts: [String] {
        get { return CustomHTTPProtocol.ignoredHosts }
        set { CustomHTTPProtocol.ignoredHosts = newValue }
    }

    /// Limit the logging count
    @objc public static var limit: NSNumber? {
        get {
            Task { @MainActor in
                return Storage.limit
            }
            return nil
        }
        set {
            Task { @MainActor in
                Storage.limit = newValue
            }
        }
    }

    /// Default filter for the search box
    @objc public static var defaultFilter: String? {
        get {
            Task { @MainActor in
                return Storage.defaultFilter
            }
            return nil
        }
        set {
            Task { @MainActor in
                Storage.defaultFilter = newValue
            }
        }
    }

    // Flag to determine if DeepChucker is enabled
    internal static var isEnabled: Bool = true
    private static var isStarted: Bool = false

    /// Method to initialize and start DeepChucker
    @objc public static func start() {
        guard !isStarted else { return }
        isStarted = true

        NotificationCenter.default.addObserver(forName: fireDeepChucker, object: nil, queue: .main) { _ in
            DeepChucker.presentDeepChuckerFlow()
        }

        setEnabled(true)
        URLSessionConfiguration.swizzleSessionConfiguration()
    }

    /// Toggles the tracking of HTTP requests in DeepChucker.
    @objc public static func setEnabled(_ enable: Bool) {
        isEnabled = enable
        if enable {
            URLProtocol.registerClass(CustomHTTPProtocol.self)
        } else {
            URLProtocol.unregisterClass(CustomHTTPProtocol.self)
        }
    }

    /// Method to enable or disable DeepChucker for a specific session configuration
    @objc public static func setEnabled(_ enable: Bool, sessionConfiguration: URLSessionConfiguration) {
        guard sessionConfiguration.responds(to: #selector(getter: URLSessionConfiguration.protocolClasses)) &&
                sessionConfiguration.responds(to: #selector(setter: URLSessionConfiguration.protocolClasses)) else {
            print("[DeepChucker] is only available when running on iOS 16+")
            return
        }

        var urlProtocolClasses = sessionConfiguration.protocolClasses ?? []
        let protoCls = CustomHTTPProtocol.self

        if enable {
            if !urlProtocolClasses.contains(where: { $0 == protoCls }) {
                urlProtocolClasses.insert(protoCls, at: 0)
            }
        } else {
            if let index = urlProtocolClasses.firstIndex(where: { $0 == protoCls }) {
                urlProtocolClasses.remove(at: index)
            }
        }
        sessionConfiguration.protocolClasses = urlProtocolClasses
    }

    /// Clears all captured network requests from DeepChucker's storage.
    @objc public static func clearRequests(completion: (() -> Void)? = nil) {
        Task { @MainActor in
            Storage.shared.clearRequests()
            completion?()
        }
    }

    /// Programmatically presents DeepChucker
    @objc public static func show() {
        DispatchQueue.main.async {
            presentDeepChuckerFlow()
        }
    }

    /// Programmatically dismisses DeepChucker
    @objc public static func dismiss() {
        DispatchQueue.main.async {
            if let currentViewController = UIViewController.currentViewController(),
               currentViewController is UIHostingController<RequestsView> {
                currentViewController.dismiss(animated: true)
            }
        }
    }

    // MARK: - Navigation
    static func presentDeepChuckerFlow() {
        if let currentViewController = UIViewController.currentViewController(),
           currentViewController is UIHostingController<RequestsView> {
            return
        }

        let requestsView = RequestsView()
        let hostingController = UIHostingController(rootView: requestsView)
        hostingController.modalPresentationStyle = .pageSheet
        if let sheet = hostingController.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.large()]
        }
        UIViewController.currentViewController()?.present(hostingController, animated: true, completion: nil)
    }

    @objc public static var shakeEnabled: Bool = {
        let key = "DEEPCHUCKER_SHAKE_ENABLED"

        if let environmentVariable = ProcessInfo.processInfo.environment[key] {
            return environmentVariable != "NO"
        }

        let arguments = UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)
        if let arg = arguments[key] {
            switch arg {
            case let boolean as Bool: return boolean
            case let string as NSString: return string.boolValue
            case let number as NSNumber: return number.boolValue
            default: break
            }
        }

        return true
    }()
}
