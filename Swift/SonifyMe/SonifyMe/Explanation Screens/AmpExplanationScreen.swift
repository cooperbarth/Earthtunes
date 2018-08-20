import Foundation
import UIKit

class AmpExplanationScreen : ViewController {
    @IBOutlet weak var ExplainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
    
    @IBAction func ExplainReturn(_ sender: Any) {
        self.removeAnimate()
    }
}

extension AmpExplanationScreen {
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        ExplainView.layer.cornerRadius = 8.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != ExplainView) {
            self.removeAnimate()
        }
    }
}
