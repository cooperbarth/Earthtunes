import Foundation
import UIKit

class ExplanationScreen : ViewController {
    @IBOutlet weak var FrequencyView: UIView!
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        FrequencyView.layer.cornerRadius = 8.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != FrequencyView) {
            self.removeAnimate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
}
