import UIKit
import AVKit
import Foundation
import AudioToolbox

class DisplayScreen : ViewController {    
    func playSound() {
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.play()
            if (player?.isPlaying)! {
                print("playing")
            }
        } catch {
            print("whoops")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSound()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
