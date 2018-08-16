import UIKit
import Foundation

class AdvancedScreen : ViewController {
    @IBOutlet weak var Freq: UISegmentedControl!
    @IBOutlet weak var Amp: UITextField!
    @IBOutlet weak var Rate: UITextField!
    @IBOutlet weak var SChannel: UISegmentedControl!
    @IBOutlet weak var GChannel: UISegmentedControl!
    @IBOutlet weak var LoopingSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Amp.delegate = self
        Rate.delegate = self
        addDoneButtons()
        
        fillIn()
    }
    
    @IBAction func FrequencyHelp(_ sender: Any) {
        showPopup(name: "FreqExplain")
    }
    
    @IBAction func AmplitudeHelp(_ sender: Any) {
        showPopup(name: "AmpExplain")
    }
    
    @IBAction func SoundChannelHelp(_ sender: Any) {
        ud.set("Sound", forKey: "ChannelHelp")
        showPopup(name: "ChannelExplain")
    }
    
    @IBAction func GraphChannelHelp(_ sender: Any) {
        ud.set("Graph", forKey: "ChannelHelp")
        showPopup(name: "ChannelExplain")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ud.set(Freq.titleForSegment(at: Freq.selectedSegmentIndex)!, forKey: "Frequency")
        ud.set(Amp.text!, forKey: "Amplitude")
        ud.set(Rate.text!, forKey: "Rate")
        ud.set(SChannel.titleForSegment(at: SChannel.selectedSegmentIndex)!, forKey: "SChannel")
        ud.set(GChannel.titleForSegment(at: GChannel.selectedSegmentIndex)!, forKey: "GChannel")
        
        ud.set(Freq.selectedSegmentIndex, forKey: "FreqIndex")
        ud.set(SChannel.selectedSegmentIndex, forKey: "SCIndex")
        ud.set(GChannel.selectedSegmentIndex, forKey: "GCIndex")
    }
    
    @IBAction func LoopingPressed(_ sender: Any) {
        ud.set(LoopingSwitch.isOn, forKey: "Loop")
    }
    
    @IBAction func ClearCache(_ sender: Any) {
        showPopup(name: "ClearCache")
    }
    
    @IBAction func ResetDefaults(_ sender: Any) {
        ud.set(3, forKey: "FreqIndex")
        ud.set("0.0001", forKey: "Amplitude")
        ud.set("1.0", forKey: "Rate")
        ud.set(0, forKey: "SCIndex")
        ud.set(1, forKey: "GCIndex")

        fillIn()
        
        ud.set(Freq.titleForSegment(at: Freq.selectedSegmentIndex)!, forKey: "Frequency")
        ud.set(SChannel.titleForSegment(at: SChannel.selectedSegmentIndex)!, forKey: "SChannel")
        ud.set(GChannel.titleForSegment(at: GChannel.selectedSegmentIndex)!, forKey: "GChannel")
    }
    
    @IBAction func ReturnButton(_ sender: Any) {
        view.endEditing(true)
        if (validInputs()) {
            performSegue(withIdentifier: "SetAdvanced", sender: self)
        } else {
            showPopup(name: "Input Error")
        }
    }
    
    func fillIn() {
        Freq.selectedSegmentIndex = ud.integer(forKey: "FreqIndex")
        Amp.text = ud.string(forKey: "Amplitude")
        Rate.text = ud.string(forKey: "Rate")
        SChannel.selectedSegmentIndex = ud.integer(forKey: "SCIndex")
        GChannel.selectedSegmentIndex = ud.integer(forKey: "GCIndex")
        LoopingSwitch.isOn = ud.bool(forKey: "Loop")
    }
    
    func addDoneButtons() {
        self.Amp.inputAccessoryView = initDoneButton()
        self.Rate.inputAccessoryView = initDoneButton()
    }
    
    func validInputs() -> Bool {
        if (Amp.text == "" || Rate.text == "") {
            ud.set("Empty Field(s)", forKey: "Input Error")
        } else {
            return true
        }
        return false
    }
}
