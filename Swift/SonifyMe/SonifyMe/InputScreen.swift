import UIKit
import AVKit
import Foundation
import AudioToolbox

class InputScreen : ViewController {
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ((segue.destination as? LoadingScreen) != nil) {
            let loadingScreen = segue.destination as? LoadingScreen
            loadingScreen?.inputLocation = ""
        }
    }
    
    @IBAction func ButtonPressed(_ sender: Any) {
        //transition to loading screen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
