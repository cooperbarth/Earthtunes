import Foundation
import UIKit

class DeleteEventScreen: ViewController {
    @IBOutlet weak var DeleteView: UIView!
    
    @IBAction func DeleteButton(_ sender: Any) {
        //delete event
        self.removeAnimate()
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        self.removeAnimate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != DeleteView) {
            self.removeAnimate()
        }
    }
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        DeleteView.layer.cornerRadius = 8.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
}
