import Foundation
import UIKit
import Photos

class AdvancedScreen : ViewController {
    @IBOutlet weak var Freq: UISegmentedControl!
    @IBOutlet weak var Amp: UITextField!
    @IBOutlet weak var Rate: UITextField!
    @IBOutlet weak var SChannel: UISegmentedControl!
    @IBOutlet weak var GChannel: UISegmentedControl!
    @IBOutlet weak var LoopingSwitch: UISwitch!
    @IBOutlet weak var SaveGraphSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtons()
        fillIn()
    }

    func showHelp(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let returnAction = UIAlertAction(title: "Return", style: .default, handler: nil)
        alertController.addAction(returnAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func ChannelHelp(expType: String) {
        let expTitle = expType + " Channel"
        let expString = channelText1 + expType.lowercased() + channelText2
        showHelp(title: expTitle, message: expString)
    }

    @IBAction func FrequencyHelp(_ sender: Any) {
        showHelp(title: "Frequency", message: freqText)
    }

    @IBAction func AmplitudeHelp(_ sender: Any) {
        showHelp(title: "Amplitude", message: ampText)
    }

    @IBAction func SoundChannelHelp(_ sender: Any) {
        ChannelHelp(expType: "Sound")
    }

    @IBAction func GraphChannelHelp(_ sender: Any) {
        ChannelHelp(expType: "Graph")
    }

    @IBAction func LoopingPressed(_ sender: Any) {
        ud.set(LoopingSwitch.isOn, forKey: "Loop")
    }

    @IBAction func SavePressed(_ sender: Any) {
        if (SaveGraphSwitch.isOn) {
            let photos = PHPhotoLibrary.authorizationStatus()
            if (photos == .notDetermined) {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized {return} else {return}
                })
            } else if (photos != .authorized) {
                let alertController = UIAlertController(title: "Save Graphs", message: saveGraphText, preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)

                present(alertController, animated: true, completion: nil)
            }
        }
        self.ud.set(self.SaveGraphSwitch.isOn, forKey: "Save")
    }

    @IBAction func ClearCache(_ sender: Any) {
        let alertController = UIAlertController(title: "Clear Cache", message: clearCacheText, preferredStyle: .alert)
        let clearCacheAction = UIAlertAction(title: "Clear", style: .default, handler: { (_) -> Void in
            saveEvents(events: [])
        })
        alertController.addAction(clearCacheAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func ResetDefaults(_ sender: Any) {
        ud.set(3, forKey: "FreqIndex")
        ud.set("0.0001", forKey: "Amplitude")
        ud.set("1.0", forKey: "Rate")
        ud.set(0, forKey: "SCIndex")
        ud.set(0, forKey: "GCIndex")

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
        SaveGraphSwitch.isOn = ud.bool(forKey: "Save")
    }
}

extension AdvancedScreen {
    func addDoneButtons() {
        Amp.delegate = self
        Rate.delegate = self
        self.Amp.inputAccessoryView = initDoneButton()
        self.Rate.inputAccessoryView = initDoneButton()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        ud.set(textField.text!, forKey: "Latest Text")
        textField.text! = ""
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if (textField.text! == "") {
            textField.text = ud.string(forKey: "Latest Text")
        }
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
