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
        formatScreen()
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
            setValues()
            performSegue(withIdentifier: "SetAdvanced", sender: self)
        } else {
            showPopup(name: "Input Error")
        }
    }
    
    func setValues() {
        ud.set(Freq.titleForSegment(at: Freq.selectedSegmentIndex)!, forKey: "Frequency")
        ud.set(Amp.text!, forKey: "Amplitude")
        ud.set(Rate.text!, forKey: "Rate")
        ud.set(SChannel.titleForSegment(at: SChannel.selectedSegmentIndex)!, forKey: "SChannel")
        ud.set(GChannel.titleForSegment(at: GChannel.selectedSegmentIndex)!, forKey: "GChannel")
        
        ud.set(Freq.selectedSegmentIndex, forKey: "FreqIndex")
        ud.set(SChannel.selectedSegmentIndex, forKey: "SCIndex")
        ud.set(GChannel.selectedSegmentIndex, forKey: "GCIndex")
    }
    
    func fillIn() {
        Freq.selectedSegmentIndex = ud.integer(forKey: "FreqIndex")
        Amp.text = ud.string(forKey: "Amplitude")
        Rate.text = ud.string(forKey: "Rate")
        SChannel.selectedSegmentIndex = ud.integer(forKey: "SCIndex")
        GChannel.selectedSegmentIndex = ud.integer(forKey: "GCIndex")
        LoopingSwitch.isOn = ud.bool(forKey: "Loop")
    }
    
    @IBOutlet weak var TopToTitleDistance: NSLayoutConstraint!
    @IBOutlet weak var AdvancedTitle: UILabel!
    @IBOutlet weak var TitleToFreqLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var FreqLabel: UIButton!
    @IBOutlet weak var FreqLabelToFreqControlDistance: NSLayoutConstraint!
    @IBOutlet weak var FreqControlToAmpLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var AmpLabel: UIButton!
    @IBOutlet weak var AmpLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var AmpLabelToAmpControlDistance: NSLayoutConstraint!
    @IBOutlet weak var AmpFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var AmpFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var AmpFieldToSoundLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var AmpFieldToGraphLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var SoundLabel: UIButton!
    @IBOutlet weak var GraphLabel: UIButton!
    @IBOutlet weak var SoundLabelXPos: NSLayoutConstraint!
    @IBOutlet weak var GraphLabelXPos: NSLayoutConstraint!
    
}

extension AdvancedScreen {
    func formatScreen() {
        TopToTitleDistance.constant = screenSize.height / 30
        AdvancedTitle.font = AdvancedTitle.font.withSize(TopToTitleDistance.constant * 0.8)
        TitleToFreqLabelDistance.constant = TopToTitleDistance.constant * 0.8
        FreqLabel.titleLabel?.font = FreqLabel.titleLabel?.font.withSize(TopToTitleDistance.constant * 0.8)
        FreqLabelToFreqControlDistance.constant = TitleToFreqLabelDistance.constant * 0.4
        let segFont = FreqLabel.titleLabel?.font!.withSize((FreqLabel.titleLabel?.font!.pointSize)! * 0.8)
        Freq.apportionsSegmentWidthsByContent = true
        Freq.setTitleTextAttributes([NSAttributedStringKey.font: segFont!], for: .normal)
        FreqControlToAmpLabelDistance.constant = TitleToFreqLabelDistance.constant * 1.5
        AmpLabel.titleLabel?.font = FreqLabel.titleLabel?.font
        AmpLabelWidth.constant = screenSize.width * 0.4
        AmpLabelToAmpControlDistance.constant = FreqLabelToFreqControlDistance.constant * 0.75
        AmpFieldWidth.constant = AmpLabelWidth.constant
        AmpFieldHeight.constant = screenSize.height / 20
        Amp.font = Amp.font?.withSize(AmpFieldHeight.constant * 0.4)
        AmpFieldToSoundLabelDistance.constant = FreqControlToAmpLabelDistance.constant
        AmpFieldToGraphLabelDistance.constant = AmpFieldToSoundLabelDistance.constant
        SoundLabel.titleLabel?.font = AmpLabel.titleLabel?.font
        GraphLabel.titleLabel?.font = SoundLabel.titleLabel?.font
        GraphLabelXPos.constant = screenSize.width / 4
        SoundLabelXPos.constant = -GraphLabelXPos.constant
        //soundchannel to soundswitch y
        //graphchannel to graphswitch y
        //soundswitch height
        //soundswitch width
        //soundswitch font size?
        //graphswitch height
        //graphswitch width
        //graphswitch font size?
        //soundswitch to playbacklabel y
        //playbacklabel font size
        //playbacklabel to playbackfield y
        //playbackfield height
        //playbackfield width
        //playbackfield to loopinglabel y
        //loopinglabel xpos
        //loopinglabel font size
        //playbackfield to loopingswitch y
        //loopingswitch xpos
        //loopingswitch height
        //loopingswitch width
        //loopinglabel to clearcache y
        //clearcache font size
        //clearcache to reset y
        //reset font size
        //reset to return y
        //return font size
    }
    
    func addDoneButtons() {
        Amp.delegate = self
        Rate.delegate = self
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
