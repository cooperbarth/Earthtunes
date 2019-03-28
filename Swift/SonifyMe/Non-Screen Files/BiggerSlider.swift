import Foundation
import UIKit

class BiggerSlider: UISlider {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bound: CGRect = self.bounds
        bound = bound.insetBy(dx: -15, dy: -15)
        return bounds.contains(point)
    }
}
