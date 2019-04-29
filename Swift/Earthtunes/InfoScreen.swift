import Foundation
import UIKit

class InfoScreen : ViewController {
    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var InfoText: UITextView!
    
    var events: [Event] = []
    let eventIndex = UserDefaults.standard.integer(forKey: "Long-Pressed Index")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InfoText.delegate = self as? UITextViewDelegate
        self.InfoText.inputAccessoryView = initDoneButton()
        events = retrieveFavorites()!
        self.makeViewAppear()
        self.showAnimate()
    }
    
    @IBAction func InfoSave(_ sender: Any) {
        events[eventIndex].descript = InfoText.text!
        saveFavorites(events: events)
        self.removeAnimate()
        savedAlert()
    }
    
    func savedAlert() {
        let alertController = UIAlertController(title: "Description Saved", message: nil, preferredStyle: .alert)
        let returnAction = UIAlertAction(title: "Return", style: .default, handler: nil)
        alertController.addAction(returnAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func InfoClose(_ sender: Any) {
        self.removeAnimate()
    }
}

extension InfoScreen {
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let editingEvent = events[eventIndex]
        InfoText.text = editingEvent.descript
        InfoView.layer.cornerRadius = 8.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != InfoView) {
            removeAnimate()
        }
    }
}
