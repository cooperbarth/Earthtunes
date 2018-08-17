import Foundation
import UIKit

class ClearCacheScreen : ViewController {
    @IBOutlet weak var CacheView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
    
    @IBAction func ClearCache(_ sender: Any) {
        saveEvents(events: [])
        self.removeAnimate()
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.removeAnimate()
    }
}

extension ClearCacheScreen {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != CacheView) {
            self.removeAnimate()
        }
    }
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        CacheView.layer.cornerRadius = 8.0
    }
}
