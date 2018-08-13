import Foundation
import UIKit

class SuggestionScreen : ViewController {
    @IBOutlet weak var SuggestionView: UIView!
    @IBOutlet weak var SuggestionScroll: UITableView!

    @IBAction func ReturnButton(_ sender: Any) {
        self.removeAnimate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != SuggestionView && touch?.view != SuggestionScroll) {
            self.removeAnimate()
        }
    }
}
