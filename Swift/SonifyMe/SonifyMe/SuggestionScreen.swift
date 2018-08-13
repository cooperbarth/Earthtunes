import Foundation
import UIKit

class SuggestionScreen : ViewController, UITableViewDelegate, UITableViewDataSource {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SuggestionScroll.dataSource = self
        SuggestionScroll.delegate = self
    }
    
    var events: [String] = [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6"
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
        let text = events[indexPath.row]
        cell.textLabel?.text = text
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
        //action.image = sdfnalksdjfalk
        action.title = "Delete"
        action.backgroundColor = UIColor.red
        
        return action
    }
}

class TableViewCell: UITableViewCell {
    
}























