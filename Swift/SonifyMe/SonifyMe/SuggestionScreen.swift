import Foundation
import UIKit

class SuggestionScreen : ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var SuggestionView: UIView!
    @IBOutlet weak var SuggestionScroll: UITableView!

    @IBAction func ReturnButton(_ sender: Any) {
        setAllFields()
        self.removeAnimate()
    }
    
    func setAllFields() {
        
        //@COOPER: THE PROBLEM WITH DURATION HAPPENS BECAUSE IT SETS WHATEVER IS IN THE BOX TO BE EQUAL TO "DURATION" IN MEMORY WHEN SWITCHING TO ADVANCED SCREEN. FIXING IT SO THAT THE FIELDS CHANGE IMMEDIATELY, RATHER THAN ON VIEWDIDLOAD, WILL FIX THIS.
        
        let selectedRow = SuggestionScroll.indexPathForSelectedRow?.row
        if (selectedRow == nil) {return}
        let Event = events[selectedRow!]
        
        ud.set(Event.location, forKey: "Location")
        ud.set(Event.date, forKey: "Date")
        ud.set(Event.time, forKey: "Time")
        ud.set(Event.duration, forKey: "Duration")
        ud.set(Event.frequency, forKey: "Frequency")
        ud.set(Event.amplitude, forKey: "Amplitude")
        ud.set(Event.rate, forKey: "Rate")
        ud.set(Event.hp, forKey: "HP")
        ud.set(Event.schannel, forKey: "SChannel")
        ud.set(Event.gchannel, forKey: "GChannel")
        
        var count = 0
        for location in ScrollMenuData {
            if (location == Event.location) {
                ud.set(count, forKey: "Location Index")
                break
            }
            count += 1
        }
        
        let frequencies = ["0.1 Hz", "0.5 Hz", "5 Hz", "10 Hz", "20 Hz", "50 Hz"]
        count = 0
        for freq in frequencies {
            if (freq == Event.frequency) {
                ud.set(count, forKey: "FreqIndex")
                break
            }
            count += 1
        }
        
        if (Event.schannel == "BHZ") {
            ud.set(0, forKey: "SCIndex")
        } else {
            ud.set(1, forKey: "SCIndex")
        }
        
        if (Event.gchannel == "BHZ") {
            ud.set(0, forKey: "GCIndex")
        } else {
            ud.set(1, forKey: "GCIndex")
        }
        
        ud.set("Set", forKey: "First")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != SuggestionView && touch?.view != SuggestionScroll) {
            setAllFields()
            self.removeAnimate()
        }
    }
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        SuggestionView.layer.cornerRadius = 8.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
        
        SuggestionScroll.dataSource = self
        SuggestionScroll.delegate = self
    }

    var events: [event] = [
        event(Location: "Yellowstone (WY,USA)", Date: "2018-07-08", Time: "00:49", Duration: "2", Frequency: "20 Hz", Amplitude: "1234", Rate: "1234", HP: "1234", SChannel: "BHZ", GChannel: "BHZ", G32: [], S32: []),
        event(Location: "ev2", Date: "", Time: "", Duration: "", Frequency: "", Amplitude: "", Rate: "", HP: "", SChannel: "", GChannel: "", G32: [], S32: [])
    ]
}

extension SuggestionScreen {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SuggestionScroll.dequeueReusableCell(withIdentifier: "Event Cell")!
        cell.textLabel?.text = events[indexPath.row].location
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            self.events.remove(at: indexPath.row)
            self.SuggestionScroll.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        })
        action.title = "Delete"
        action.backgroundColor = UIColor.red
        
        return action
    }
}

class TableViewCell: UITableViewCell {
    
}























