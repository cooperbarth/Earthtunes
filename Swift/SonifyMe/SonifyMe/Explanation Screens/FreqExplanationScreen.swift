import Foundation
import UIKit

class FreqExplanationScreen : ViewController {
    @IBOutlet weak var ExplainView: UIView!
    
    @IBAction func ExplainReturn(_ sender: Any) {
        self.removeAnimate()
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
}
