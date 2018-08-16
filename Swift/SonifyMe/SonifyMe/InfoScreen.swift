import Foundation
import UIKit

class InfoScreen : ViewController {
    //text box, cancel, and save buttons
    //events need to have a "description" field (string)
    //on load, set the textbox.text = event.description
    //on clicking save, set event.description = textbox.text and close it
    
    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var InfoText: UITextView!
    
    @IBAction func InfoSave(_ sender: Any) {
        self.removeAnimate()
    }
    
    @IBAction func InfoClose(_ sender: Any) {
        self.removeAnimate()
    }
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        //InfoText.text =
        InfoView.layer.cornerRadius = 8.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }
}
