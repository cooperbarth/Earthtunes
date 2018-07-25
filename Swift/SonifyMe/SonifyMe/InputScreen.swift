import UIKit
import AVKit
import Foundation
import AudioToolbox

class InputScreen : ViewController {
    
    @IBOutlet weak var LocationField: UITextField!
    @IBOutlet weak var DateField: UITextField!
    @IBOutlet weak var TimeField: UITextField!
    @IBOutlet weak var DurationField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ((segue.destination as? LoadingScreen) != nil) {
            let loadingScreen = segue.destination as? LoadingScreen
            loadingScreen?.inputLocation = LocationField.text!
            loadingScreen?.inputDate = DateField.text!
            loadingScreen?.inputTime = TimeField.text!
            loadingScreen?.inputDuration = DurationField.text!
        }
    }
    
    @IBAction func ButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToLoading", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
