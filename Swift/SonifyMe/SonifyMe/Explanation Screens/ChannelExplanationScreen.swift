import Foundation
import UIKit

class ChannelExplanationScreen : ViewController {
    var channelType: String = ""
    
    @IBOutlet weak var ChannelView: UIView!
    @IBOutlet weak var ChannelLabel: UILabel!
    @IBOutlet weak var ChannelDescript: UILabel!
    
    @IBAction func ReturnButton(_ sender: Any) {
        self.removeAnimate()
    }
    
    func makeViewAppear() {
        if (channelType == "Sound") {
            ChannelLabel.text = "Sound Channel"
            ChannelDescript.text = "Controls the channel from which the data for the sound is retrieved. BHZ will retrieve more data points than LHZ, but will take much longer to load."
        } else {
            ChannelLabel.text = "Graph Channel"
            ChannelDescript.text = "Controls the channel from which the data for the graph is retrieved. BHZ will retrieve more data points than LHZ, but will take much longer to load."
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        ChannelView.layer.cornerRadius = 8.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if (touch?.view != ChannelView) {
            self.removeAnimate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelType = ud.string(forKey: "ChannelHelp")!
        self.makeViewAppear()
        self.showAnimate()
    }
}
