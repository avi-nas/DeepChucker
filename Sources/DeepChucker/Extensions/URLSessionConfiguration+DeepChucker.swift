import Foundation

extension URLSessionConfiguration {
    private static var isSwizzled: Bool = false
    
    internal static func swizzleSessionConfiguration() {
        guard !isSwizzled else { return }
        isSwizzled = true
        
        let cls = URLSessionConfiguration.self
        
        // Swizzle defaultSessionConfiguration
        let defaultSelector = Selector("defaultSessionConfiguration")
        let swizzledDefaultSelector = #selector(URLSessionConfiguration.dc_defaultSessionConfiguration)
        
        if let originalDefaultMethod = class_getClassMethod(cls, defaultSelector),
           let swizzledDefaultMethod = class_getClassMethod(cls, swizzledDefaultSelector) {
            method_exchangeImplementations(originalDefaultMethod, swizzledDefaultMethod)
        }
        
        // Swizzle ephemeralSessionConfiguration
        let ephemeralSelector = Selector("ephemeralSessionConfiguration")
        let swizzledEphemeralSelector = #selector(URLSessionConfiguration.dc_ephemeralSessionConfiguration)
        
        if let originalEphemeralMethod = class_getClassMethod(cls, ephemeralSelector),
           let swizzledEphemeralMethod = class_getClassMethod(cls, swizzledEphemeralSelector) {
            method_exchangeImplementations(originalEphemeralMethod, swizzledEphemeralMethod)
        }
    }
    
    @objc private dynamic class func dc_defaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = dc_defaultSessionConfiguration()
        DeepChucker.setEnabled(true, sessionConfiguration: configuration)
        return configuration
    }
    
    @objc private dynamic class func dc_ephemeralSessionConfiguration() -> URLSessionConfiguration {
        let configuration = dc_ephemeralSessionConfiguration()
        DeepChucker.setEnabled(true, sessionConfiguration: configuration)
        return configuration
    }
}
