import UIKit
import AVKit
import Foundation
import AudioToolbox
import CorePlot

class DisplayScreen : ViewController {
    var data : [Float64] = [Float64]()
    
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
    
    @IBOutlet weak var hostView: CPTGraphHostingView!
}
