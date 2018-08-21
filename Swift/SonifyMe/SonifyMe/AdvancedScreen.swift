import UIKit
import Foundation

class AdvancedScreen : ViewController {
    @IBOutlet weak var Freq: UISegmentedControl!
    @IBOutlet weak var Amp: UITextField!
    @IBOutlet weak var Rate: UITextField!
    @IBOutlet weak var SChannel: UISegmentedControl!
    @IBOutlet weak var GChannel: UISegmentedControl!
    @IBOutlet weak var LoopingSwitch: UISwitch!
    
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
    @IBOutlet weak var SoundLabelToSwitchDistance: NSLayoutConstraint!
    @IBOutlet weak var GraphLabelToSwitchDistance: NSLayoutConstraint!
    @IBOutlet weak var SoundSwitchToRateLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var RateLabel: UILabel!
    @IBOutlet weak var RateLabelToFieldDistance: NSLayoutConstraint!
    @IBOutlet weak var RateFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var RateFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var RateFieldToLoopingLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var LoopingLabelXPos: NSLayoutConstraint!
    @IBOutlet weak var LoopingSwitchXPos: NSLayoutConstraint!
    @IBOutlet weak var LoopingLabel: UILabel!
    @IBOutlet weak var SaveGraphsLabelXPos: NSLayoutConstraint!
    @IBOutlet weak var SaveGraphsSwitchXPos: NSLayoutConstraint!
    @IBOutlet weak var SaveGraphsLabel: UILabel!
    @IBOutlet weak var LoopingLabelToClearDistance: NSLayoutConstraint!
    @IBOutlet weak var ClearCacheLabel: UIButton!
    @IBOutlet weak var ClearToResetLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var ResetLabel: UIButton!
    @IBOutlet weak var ResetToReturnLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var ReturnLabel: UIButton!
    
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
}

extension AdvancedScreen {
    func formatScreen() {
        switch screenSize.height {
        case 1136.0:
            format1136Screen()
            break
        case 2208.0:
            format2208Screen()
            break
        case 2436.0:
            format2436Screen()
            break
        default:
            break
        }
    }
    
    func format1136Screen() {
        TopToTitleDistance.constant = screenSize.height * 0.02
        AdvancedTitle.font = AdvancedTitle.font.withSize(TopToTitleDistance.constant * 0.8)
        TitleToFreqLabelDistance.constant = TopToTitleDistance.constant * 0.5
        FreqLabel.titleLabel?.font = FreqLabel.titleLabel?.font.withSize(TopToTitleDistance.constant * 0.65)
        FreqLabelToFreqControlDistance.constant = TitleToFreqLabelDistance.constant * 0.4
        let segFont = FreqLabel.titleLabel?.font!.withSize((FreqLabel.titleLabel?.font!.pointSize)! * 0.8)
        Freq.apportionsSegmentWidthsByContent = true
        Freq.setTitleTextAttributes([NSAttributedStringKey.font: segFont!], for: .normal)
        FreqControlToAmpLabelDistance.constant = TitleToFreqLabelDistance.constant * 1.35
        AmpLabel.titleLabel?.font = FreqLabel.titleLabel?.font
        AmpLabelWidth.constant = screenSize.width * 0.25
        AmpLabelToAmpControlDistance.constant = FreqLabelToFreqControlDistance.constant * 0.75
        AmpFieldWidth.constant = AmpLabelWidth.constant
        AmpFieldHeight.constant = screenSize.height * 0.03
        Amp.font = Amp.font?.withSize(AmpFieldHeight.constant * 0.4)
        AmpFieldToSoundLabelDistance.constant = FreqControlToAmpLabelDistance.constant * 1.35
        AmpFieldToGraphLabelDistance.constant = AmpFieldToSoundLabelDistance.constant
        SoundLabel.titleLabel?.font = AmpLabel.titleLabel?.font
        GraphLabel.titleLabel?.font = SoundLabel.titleLabel?.font
        GraphLabelXPos.constant = screenSize.width * 0.1
        SoundLabelXPos.constant = -GraphLabelXPos.constant
        SoundLabelToSwitchDistance.constant = AmpLabelToAmpControlDistance.constant
        GraphLabelToSwitchDistance.constant = SoundLabelToSwitchDistance.constant
        SChannel.apportionsSegmentWidthsByContent = true
        SChannel.setTitleTextAttributes([NSAttributedStringKey.font: segFont!], for: .normal)
        GChannel.apportionsSegmentWidthsByContent = true
        GChannel.setTitleTextAttributes([NSAttributedStringKey.font: segFont!], for: .normal)
        SoundSwitchToRateLabelDistance.constant = AmpFieldToGraphLabelDistance.constant * 1.35
        RateLabel.font = SoundLabel.titleLabel?.font
        RateLabelToFieldDistance.constant = AmpLabelToAmpControlDistance.constant * 1.5
        Rate.font = Amp.font
        RateFieldWidth.constant = AmpFieldWidth.constant
        RateFieldHeight.constant = AmpFieldHeight.constant
        RateFieldToLoopingLabelDistance.constant = SoundSwitchToRateLabelDistance.constant
        LoopingLabel.font = Amp.font
        LoopingSwitchXPos.constant = -45
        LoopingLabelXPos.constant = -100
        SaveGraphsLabel.font = LoopingLabel.font
        SaveGraphsLabelXPos.constant = 40
        SaveGraphsSwitchXPos.constant = 110
        LoopingLabelToClearDistance.constant = SoundSwitchToRateLabelDistance.constant * 0.75
        ClearCacheLabel.titleLabel?.font = AmpLabel.titleLabel?.font.withSize(TopToTitleDistance.constant * 0.65)
        ClearToResetLabelDistance.constant = screenSize.height * 0.0075
        ResetLabel.titleLabel?.font = AmpLabel.titleLabel?.font
        ResetToReturnLabelDistance.constant = ClearToResetLabelDistance.constant
        ReturnLabel.titleLabel?.font = AmpLabel.titleLabel?.font
    }
    
    func format2208Screen() {
        TopToTitleDistance.constant = 22
        AdvancedTitle.font = AdvancedTitle.font.withSize(22)
        TitleToFreqLabelDistance.constant = TopToTitleDistance.constant
        FreqLabel.titleLabel?.font = FreqLabel.titleLabel?.font.withSize(16)
        FreqLabelToFreqControlDistance.constant = TitleToFreqLabelDistance.constant * 0.4
        FreqControlToAmpLabelDistance.constant = TitleToFreqLabelDistance.constant * 1.5
        AmpLabel.titleLabel?.font = FreqLabel.titleLabel?.font
        AmpLabelWidth.constant = screenSize.width * 0.25
        AmpLabelToAmpControlDistance.constant = FreqLabelToFreqControlDistance.constant * 0.75
        AmpFieldWidth.constant = AmpLabelWidth.constant * 0.6
        AmpFieldHeight.constant = screenSize.height * 0.015
        Amp.font = Amp.font?.withSize(AmpFieldHeight.constant * 0.4)
        AmpFieldToSoundLabelDistance.constant = FreqControlToAmpLabelDistance.constant
        AmpFieldToGraphLabelDistance.constant = AmpFieldToSoundLabelDistance.constant
        SoundLabel.titleLabel?.font = AmpLabel.titleLabel?.font
        GraphLabel.titleLabel?.font = SoundLabel.titleLabel?.font
        GraphLabelXPos.constant = screenSize.width * 0.075
        SoundLabelXPos.constant = -GraphLabelXPos.constant
        SoundLabelToSwitchDistance.constant = AmpLabelToAmpControlDistance.constant
        GraphLabelToSwitchDistance.constant = SoundLabelToSwitchDistance.constant
        SoundSwitchToRateLabelDistance.constant = AmpFieldToGraphLabelDistance.constant * 1.25
        RateLabel.font = SoundLabel.titleLabel?.font
        RateLabelToFieldDistance.constant = AmpLabelToAmpControlDistance.constant
        Rate.font = Amp.font
        RateFieldWidth.constant = AmpFieldWidth.constant
        RateFieldHeight.constant = AmpFieldHeight.constant
        RateFieldToLoopingLabelDistance.constant = SoundSwitchToRateLabelDistance.constant
        LoopingLabel.font = RateLabel.font
        LoopingSwitchXPos.constant = -62
        LoopingLabelXPos.constant = -125
        SaveGraphsLabel.font = LoopingLabel.font
        SaveGraphsLabelXPos.constant = 55
        SaveGraphsSwitchXPos.constant = 133
        LoopingLabelToClearDistance.constant = SoundSwitchToRateLabelDistance.constant
        ClearCacheLabel.titleLabel?.font = AmpLabel.titleLabel?.font
        ClearToResetLabelDistance.constant = screenSize.height * 0.0075
        ResetLabel.titleLabel?.font = AmpLabel.titleLabel?.font
        ResetToReturnLabelDistance.constant = ClearToResetLabelDistance.constant
        ReturnLabel.titleLabel?.font = AmpLabel.titleLabel?.font
    }
    
    func format2436Screen() {
        format2208Screen()
        AdvancedTitle.font = AdvancedTitle.font.withSize(28)
        RateFieldToLoopingLabelDistance.constant = SoundSwitchToRateLabelDistance.constant * 1.5
        LoopingLabelToClearDistance.constant = SoundSwitchToRateLabelDistance.constant * 1.35
    }
}

extension AdvancedScreen {
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
