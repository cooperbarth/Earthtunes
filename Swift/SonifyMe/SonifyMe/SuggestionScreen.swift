import Foundation
import UIKit

class SuggestionScreen : ViewController, UITableViewDelegate, UITableViewDataSource {
    var events : [event] = []
    
    @IBOutlet weak var SuggestionView: UIView!
    @IBOutlet weak var SuggestionScroll: UITableView!

    @IBAction func ReturnButton(_ sender: Any) {
        setAllFields()
        UIView.setAnimationsEnabled(false)
        performSegue(withIdentifier: "Select Event", sender: self)
    }
    
    func setAllFields() {
        saveFavorites(events: self.events)
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
            removeAnimate()
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
        
        
        events = retrieveFavorites()!
        
        SuggestionScroll.dataSource = self
        SuggestionScroll.delegate = self
    }
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
        let locationString: String = events[indexPath.row].location
        var index : Int = 0
        var ct = 0
        for character in locationString {
            if (character == "(") {
                index = max(ct - 1, 0)
                break
            } else if (character == ",") {
                index = ct
                break
            }
            ct += 1
        }
        if (index != 0) {
            let subLocation = locationString.prefix(index)
            cell.textLabel?.text = subLocation + ": " + events[indexPath.row].date
        } else {
            cell.textLabel?.text = locationString + ": " + events[indexPath.row].date
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.4)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            self.events.remove(at: indexPath.row)
            saveFavorites(events: self.events)
            self.SuggestionScroll.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        })
        action.title = "Delete"
        action.backgroundColor = UIColor.red
        
        return action
    }
}























