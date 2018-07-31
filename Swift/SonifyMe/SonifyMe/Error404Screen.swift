import Foundation
import UIKit

class Error404Screen : ViewController {
    @IBOutlet weak var InputErrorLabel: UILabel!
    
    @IBAction func CloseButton(_ sender: Any) {
        self.removeAnimate()
        performSegue(withIdentifier: "Finished404", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        InputErrorLabel.text = "Error 404: The Requested\n Data is Unavailable"
        self.showAnimate()
    }
}
