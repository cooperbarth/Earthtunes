import UIKit
import Foundation

class AdvancedScreen : ViewController {
    @IBOutlet weak var Freq: UISegmentedControl!
    @IBOutlet weak var Amp: UITextField!
    @IBOutlet weak var Rate: UITextField!
    @IBOutlet weak var HP: UITextField!
    @IBOutlet weak var SChannel: UISegmentedControl!
    @IBOutlet weak var GChannel: UISegmentedControl!
    
    func validInputs() -> Bool {
        if (Amp.text == "" || Rate.text == "" || HP.text == "") {return false}
        if (!isNumber(num: Amp.text!) || !isNumber(num: Rate.text!) || !isNumber(num: HP.text!)) {return false}
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Amp.delegate = self
        Rate.delegate = self
        HP.delegate = self
        
        if (ud.string(forKey: "Amplitude") == nil) {
            ud.set("0.0001", forKey: "Amplitude")
        }
        if (ud.string(forKey: "Rate") == nil) {
            ud.set("1.0", forKey: "Rate")
        }
        if (ud.string(forKey: "HP") == nil) {
            ud.set("0.001", forKey: "HP")
        }
        
        if (ud.string(forKey: "First") == nil) {
            ud.set(4, forKey: "FreqIndex")
            ud.set(0, forKey: "SCIndex")
            ud.set(1, forKey: "GCIndex")
            ud.set("Set", forKey: "First")
        }
        fillIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ud.set(Freq.titleForSegment(at: Freq.selectedSegmentIndex)!, forKey: "Frequency")
        ud.set(Amp.text!, forKey: "Amplitude")
        ud.set(Rate.text!, forKey: "Rate")
        ud.set(HP.text!, forKey: "HP")
        ud.set(SChannel.titleForSegment(at: SChannel.selectedSegmentIndex)!, forKey: "SChannel")
        ud.set(GChannel.titleForSegment(at: GChannel.selectedSegmentIndex)!, forKey: "GChannel")
        
        ud.set(Freq.selectedSegmentIndex, forKey: "FreqIndex")
        ud.set(SChannel.selectedSegmentIndex, forKey: "SCIndex")
        ud.set(GChannel.selectedSegmentIndex, forKey: "GCIndex")
    }
    
    @IBAction func ResetDefaults(_ sender: Any) {
        ud.set(4, forKey: "FreqIndex")
        ud.set("0.0001", forKey: "Amplitude")
        ud.set("1.0", forKey: "Rate")
        ud.set("0.001", forKey: "HP")
        ud.set(0, forKey: "SCIndex")
        ud.set(1, forKey: "GCIndex")

        fillIn()
        
        ud.set(Freq.titleForSegment(at: Freq.selectedSegmentIndex)!, forKey: "Frequency")
        ud.set(SChannel.titleForSegment(at: SChannel.selectedSegmentIndex)!, forKey: "SChannel")
        ud.set(GChannel.titleForSegment(at: GChannel.selectedSegmentIndex)!, forKey: "GChannel")
    }
    
    func fillIn() {
        Freq.selectedSegmentIndex = ud.integer(forKey: "FreqIndex")
        Amp.text = ud.string(forKey: "Amplitude")
        Rate.text = ud.string(forKey: "Rate")
        HP.text = ud.string(forKey: "HP")
        SChannel.selectedSegmentIndex = ud.integer(forKey: "SCIndex")
        GChannel.selectedSegmentIndex = ud.integer(forKey: "GCIndex")
    }
    
    @IBAction func ReturnButton(_ sender: Any) {
        if (validInputs()) {
            performSegue(withIdentifier: "SetAdvanced", sender: self)
        }
    }
}
