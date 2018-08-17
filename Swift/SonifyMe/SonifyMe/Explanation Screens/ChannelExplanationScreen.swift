import Foundation
import UIKit

class ChannelExplanationScreen : ViewController {
    @IBOutlet weak var ChannelView: UIView!
    @IBOutlet weak var ChannelLabel: UILabel!
    @IBOutlet weak var ChannelDescript: UILabel!
    
    var channelType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelType = ud.string(forKey: "ChannelHelp")!
        self.makeViewAppear()
        self.showAnimate()
    }
    
    @IBAction func ReturnButton(_ sender: Any) {
        self.removeAnimate()
    }
}

extension ChannelExplanationScreen {
    func makeViewAppear() {
        if (channelType == "Sound") {
            ChannelLabel.text = "Sound Channel"
            ChannelDescript.text = soundExplain
        } else {
            ChannelLabel.text = "Graph Channel"
            ChannelDescript.text = graphExplain
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
}
