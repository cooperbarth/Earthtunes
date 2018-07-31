import Foundation
import UIKit

class InputErrorScreen : ViewController {
    @IBOutlet weak var InputErrorLabel: UILabel!
    
    @IBAction func CloseButton(_ sender: Any) {
        self.removeAnimate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.InputErrorLabel.text = "Input Error:\n" + ud.string(forKey: "Input Error")!
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
    }
}
