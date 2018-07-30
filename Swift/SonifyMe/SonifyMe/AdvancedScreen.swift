import UIKit
import Foundation

class AdvancedScreen : ViewController {
    var inpFreq : Int = 4
    var inpAmp : String = "0.0001"
    var inpRate : String = "1.0"
    var inpHP : String = "0.001"
    var inpSChannel : Int = 0
    var inpGChannel : Int = 1
    
    @IBOutlet weak var Freq: UISegmentedControl!
    @IBOutlet weak var Amp: UITextField!
    @IBOutlet weak var Rate: UITextField!
    @IBOutlet weak var HP: UITextField!
    @IBOutlet weak var SChannel: UISegmentedControl!
    @IBOutlet weak var GChannel: UISegmentedControl!
    
    override func validInputs() -> Bool {
        if (Amp.text == "" || Rate.text == "" || HP.text == "") {return false}
        if (!isNumber(num: Amp.text!) || !isNumber(num: Rate.text!) || !isNumber(num: HP.text!)) {return false}
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Freq.selectedSegmentIndex = inpFreq
        Amp.text = inpAmp
        Rate.text = inpRate
        HP.text = inpHP
        SChannel.selectedSegmentIndex = inpSChannel
        GChannel.selectedSegmentIndex = inpGChannel
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
            
            inputScreen?.freqvalue = Freq.titleForSegment(at: Freq.selectedSegmentIndex)!
            inputScreen?.svalue = SChannel.titleForSegment(at: SChannel.selectedSegmentIndex)!
            inputScreen?.gvalue = GChannel.titleForSegment(at: GChannel.selectedSegmentIndex)!
        }
    }
    
    @IBAction func ReturnButton(_ sender: Any) {
        if (validInputs()) {
            performSegue(withIdentifier: "SetAdvanced", sender: self)
        }
    }
}
