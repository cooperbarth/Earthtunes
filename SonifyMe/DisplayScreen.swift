import Foundation

class DisplayScreen: ViewController {
    
    @IBAction func BackButton() {
        performSegue(withIdentifier: "Back", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
