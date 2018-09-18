import Foundation
import UIKit

class SuggestionScreen : ViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var SuggestionView: UIView!
    @IBOutlet weak var SuggestionScroll: UITableView!
    
    var events : [event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
        self.setUpLongPress()

        firstTime()
        events = retrieveFavorites()!
        
        SuggestionScroll.dataSource = self
        SuggestionScroll.delegate = self
    }

    @IBAction func ReturnButton(_ sender: Any) {
        setAllFields()
        UIView.setAnimationsEnabled(false)
        performSegue(withIdentifier: "Select Event", sender: self)
    }
    
    func firstTime() {
        if (!ud.bool(forKey: "Opened Suggestion Previously?")) {
            ud.set(true, forKey: "Opened Suggestion Previously?")
            let alertController = UIAlertController(title: "Saved Events", message: suggestionIntroText, preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "Continue", style: .default)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
        }
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
}

extension SuggestionScreen {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != SuggestionView && touch?.view != SuggestionScroll) {
            removeAnimate()
        }
    }
    
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        SuggestionView.layer.cornerRadius = 8.0
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Optima", size: 18)!
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete!])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction? {
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completion) in
            let alertController = UIAlertController(title: "Delete Event", message: deleteEventText, preferredStyle: .alert)
            let clearCacheAction = UIAlertAction(title: "Delete", style: .default, handler: { (_) -> Void in
                self.events.remove(at: indexPath.row)
                saveFavorites(events: self.events)
                self.SuggestionScroll.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            })
            alertController.addAction(clearCacheAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (_) -> Void in
                completion(false)
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        })
        action.title = "Delete"
        action.backgroundColor = UIColor.red
        
        return action
    }
    
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = longPressGestureRecognizer.location(in: self.SuggestionScroll)
        if let indexPath = SuggestionScroll.indexPathForRow(at: touchPoint) {
            if (longPressGestureRecognizer.state == UIGestureRecognizer.State.began) {
                view.endEditing(true)
                ud.set(indexPath.row, forKey: "Long-Pressed Index")
                showPopup(name: "Info Screen")
            }
        }
    }
    
    func setUpLongPress() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressGesture.minimumPressDuration = 0.65
        longPressGesture.delegate = self
        self.SuggestionScroll.addGestureRecognizer(longPressGesture)
    }
}
