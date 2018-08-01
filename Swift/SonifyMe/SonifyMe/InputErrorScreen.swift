import Foundation
import UIKit

class InputErrorScreen : ViewController {
    @IBOutlet weak var InputErrorView: UIView!
    @IBOutlet weak var InputErrorLabel: UILabel!
    
    @IBAction func CloseButton(_ sender: Any) {
        self.removeAnimate()
    }
    
    func makeViewAppear() {
        self.InputErrorLabel.text = "Input Error:\n" + ud.string(forKey: "Input Error")!
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        InputErrorView.layer.cornerRadius = 8.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
}
