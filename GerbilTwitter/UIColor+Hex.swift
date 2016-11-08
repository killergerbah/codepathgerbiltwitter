import UIKit

extension UIColor {
    
    convenience init?(hex: String) {
        var value: UInt32 = 0
        guard Scanner(string: hex).scanHexInt32(&value) else {
            return nil
        }
        
        self.init(red: CGFloat((value & 0xFF0000) >> 16) / 255, green: CGFloat((value & 0x00FF00) >> 8) / 255, blue: CGFloat(value & 0x0000FF) / 255, alpha: 1.0)
    }
}
