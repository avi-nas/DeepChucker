import UIKit

extension UIViewController {
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake && DeepChucker.shakeEnabled {
            NotificationCenter.default.post(name: fireDeepChucker, object: nil)
        }
        
        next?.motionBegan(motion, with: event)
    }
}
