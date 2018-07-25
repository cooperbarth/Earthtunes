import UIKit
import AVKit
import Foundation
import AudioToolbox

class ViewController: UIViewController {
    
    let url = Bundle.main.url(forResource: "sound", withExtension: "wav")
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

