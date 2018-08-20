import Foundation
import UIKit

class InputErrorScreen : ViewController {
    @IBOutlet weak var InputErrorView: UIView!
    @IBOutlet weak var InputErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
    
    @IBAction func CloseButton(_ sender: Any) {
        self.removeAnimate()
    }
}

extension InputErrorScreen {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != InputErrorView) {
            self.removeAnimate()
        }
    }
    
    func makeViewAppear() {
        self.InputErrorLabel.text = "Input Error:\n" + ud.string(forKey: "Input Error")!
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        InputErrorView.layer.cornerRadius = 8.0
    }
}
