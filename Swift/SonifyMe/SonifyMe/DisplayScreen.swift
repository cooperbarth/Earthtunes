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

extension DisplayScreen: CPTPieChartDataSource, CPTPieChartDelegate {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 0
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        return 0
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        return nil
    }
    
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        return nil
    }
    
    func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
        return nil
    }
}
