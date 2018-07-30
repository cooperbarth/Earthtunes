import UIKit
import Foundation

class AdvancedScreen : ViewController {
    var inputFreq : Int = 4
    var inputAmp : String = "0.0001"
    var inputRate : String = "1.0"
    var inputHP : String = "0.001"
    var inputSChannel : Int = 0
    var inputGChannel : Int = 1
    
    @IBOutlet weak var Freq: UISegmentedControl!
    @IBOutlet weak var Amp: UITextField!
    @IBOutlet weak var Rate: UITextField!
    @IBOutlet weak var HP: UITextField!
    @IBOutlet weak var SChannel: UISegmentedControl!
    @IBOutlet weak var GChannel: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Freq.selectedSegmentIndex = inputFreq
        Amp.text = inputAmp
        Rate.text = inputRate
        HP.text = inputHP
        SChannel.selectedSegmentIndex = inputSChannel
        GChannel.selectedSegmentIndex = inputGChannel
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ((segue.destination as? InputScreen) != nil) {
            let inputScreen = segue.destination as? InputScreen
            inputScreen?.freq = Freq.selectedSegmentIndex
            inputScreen?.amp = Amp.text!
            inputScreen?.rate = Rate.text!
            inputScreen?.hp = HP.text!
            inputScreen?.schannel = SChannel.selectedSegmentIndex
            inputScreen?.gchannel = GChannel.selectedSegmentIndex
        }
    }
    
    @IBAction func ReturnButton(_ sender: Any) {
        performSegue(withIdentifier: "SetAdvanced", sender: self)
    }
}
