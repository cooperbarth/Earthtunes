import Foundation
import UIKit

class InfoScreen : ViewController {
    var events: [event] = []
    let eventIndex = UserDefaults.standard.integer(forKey: "Long-Pressed Index")
    
    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var InfoText: UITextView!
    
    @IBAction func InfoSave(_ sender: Any) {
        events[eventIndex].descript = InfoText.text!
        saveFavorites(events: events)
    }
    
    @IBAction func InfoClose(_ sender: Any) {
        self.removeAnimate()
    }
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let editingEvent = events[eventIndex]
        InfoText.text = editingEvent.descript
        InfoView.layer.cornerRadius = 8.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        events = retrieveFavorites()!
        self.makeViewAppear()
        self.showAnimate()
    }
}
