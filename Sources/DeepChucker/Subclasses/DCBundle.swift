import UIKit

internal class DCBundle: Bundle {
    static func getBundle() -> Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let frameworkBundle = Bundle(for: DeepChucker.classForCoder())
        if let bundleURL = frameworkBundle.url(forResource: "DeepChuckerResources", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        
        return Bundle(for: DeepChucker.classForCoder())
        #endif
    }
}
