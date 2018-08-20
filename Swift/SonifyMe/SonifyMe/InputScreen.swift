import UIKit
import Foundation

class InputScreen : ViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var LocationField: UIPickerView!
    @IBOutlet weak var DateField: UIDatePicker!
    @IBOutlet weak var TimeField: UIDatePicker!
    @IBOutlet weak var DurationField: UITextField!
    
    @IBOutlet weak var TitleDistanceFromTop: NSLayoutConstraint!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var TitleToLocationDistance: NSLayoutConstraint!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var LocationLabelToSpinnerDistance: NSLayoutConstraint!
    @IBOutlet weak var LocationSpinnerHeight: NSLayoutConstraint!
    @IBOutlet weak var LocationSpinnerWidth: NSLayoutConstraint!
    @IBOutlet weak var LocationSpinnerToDateLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var DateLabelToSpinnerDistance: NSLayoutConstraint!
    @IBOutlet weak var DateSpinnerHeight: NSLayoutConstraint!
    @IBOutlet weak var DateSpinnerWidth: NSLayoutConstraint!
    @IBOutlet weak var DateSpinnerToTimeLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var TimeLabelToSpinnerDistance: NSLayoutConstraint!
    @IBOutlet weak var TimeSpinnerHeight: NSLayoutConstraint!
    @IBOutlet weak var TimeSpinnerWidth: NSLayoutConstraint!
    @IBOutlet weak var TimeSpinnerToDurationLabelDistance: NSLayoutConstraint!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var DurationLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var DurationLabelToFieldDistance: NSLayoutConstraint!
    @IBOutlet weak var DurationTextFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var DurationFieldTextHeight: NSLayoutConstraint!
    @IBOutlet weak var DurationFieldToSavedEventsDistance: NSLayoutConstraint!
    @IBOutlet weak var SavedEventsLabel: UIButton!
    @IBOutlet weak var SavedToAdvancedDistance: NSLayoutConstraint!
    @IBOutlet weak var AdvancedOptionsLabel: UIButton!
    @IBOutlet weak var AdvancedToSubmitDistance: NSLayoutConstraint!
    @IBOutlet weak var SubmitLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatScreen()
        UIView.setAnimationsEnabled(true)
        
        LocationField.delegate = self
        LocationField.dataSource = self
        DurationField.delegate = self
        
        DateField.maximumDate = Date()
        df1.dateFormat = "YYYY-MM-dd"
        df2.dateFormat = "HH:mm"
        
        self.DurationField.inputAccessoryView = initDoneButton()
        setUpFields()
    }
    
    @IBAction func DateChanged(_ sender: Any) {
        ud.set(df1.string(from: DateField.date), forKey: "Date")
    }
    
    @IBAction func TimeChanged(_ sender: Any) {
        ud.set(df2.string(from: TimeField.date), forKey: "Time")
    }
    
    @IBAction func SamplePressed(_ sender: Any) {
        view.endEditing(true)
        showPopup(name: "Suggestion Screen")
    }
    
    @IBAction func AdvancedPressed(_ sender: Any) {
        ud.set(DurationField.text!, forKey: "Duration")
        performSegue(withIdentifier: "ToAdvanced", sender: self)
    }
    
    @IBAction func ButtonPressed(_ sender: Any) {
        view.endEditing(true)
        if (!validInputs()) {
            showPopup(name: "Input Error")
        } else {
            ud.set(DurationField.text!, forKey: "Duration")
            showPopup(name: "Loading Screen")
        }
    }
    
    func setUpFields() {
        if (ud.string(forKey: "Location") == nil) {
            ud.set("Ryerson (IL,USA)", forKey: "Location")
        }
        if (ud.string(forKey: "Date") == nil) {
            ud.set(df1.string(from: Date()), forKey: "Date")
        }
        if (ud.string(forKey: "Time") == nil) {
            ud.set("00:00", forKey: "Time")
        }
        if (ud.string(forKey: "Duration") == nil) {
            ud.set("2", forKey: "Duration")
        }
        LocationField.selectRow(ud.integer(forKey: "Location Index"), inComponent: 0, animated: false)
        DateField.date = df1.date(from: ud.string(forKey: "Date")!)!
        TimeField.date = df2.date(from: ud.string(forKey: "Time")!)!
        DurationField.text = ud.string(forKey: "Duration")

        
        if (ud.string(forKey: "Amplitude") == nil) {
            ud.set("0.0001", forKey: "Amplitude")
        }
        if (ud.string(forKey: "Rate") == nil) {
            ud.set("1.0", forKey: "Rate")
        }
        
        if (ud.string(forKey: "First") == nil) {
            ud.set(3, forKey: "FreqIndex")
            ud.set(0, forKey: "SCIndex")
            ud.set(1, forKey: "GCIndex")
            ud.set("10 Hz", forKey: "Frequency")
            ud.set("BHZ", forKey: "SChannel")
            ud.set("LHZ", forKey: "GChannel")
            
            saveEvents(events: [])
            let favorites = defaultEvents
            saveFavorites(events: favorites)
            
            ud.set("Set", forKey: "First")
        }
    }
}

extension InputScreen {
    func formatScreen() {
        TitleDistanceFromTop.constant = screenSize.height * 0.01
        TitleLabel.font = UIFont(name: TitleLabel.font.fontName, size: screenSize.height / 35)
        TitleToLocationDistance.constant = TitleDistanceFromTop.constant
        LocationLabel.font = LocationLabel.font.withSize(screenSize.height / 65)
        LocationLabelToSpinnerDistance.constant = -screenSize.height * 0.005
        LocationSpinnerHeight.constant = screenSize.height / 15
        LocationSpinnerWidth.constant = LocationSpinnerHeight.constant * 3.2
        LocationSpinnerToDateLabelDistance.constant = TitleToLocationDistance.constant * 0.6
        DateLabel.font = LocationLabel.font
        DateLabelToSpinnerDistance.constant = 0
        DateSpinnerHeight.constant = LocationSpinnerHeight.constant
        DateSpinnerWidth.constant = LocationSpinnerWidth.constant
        DateSpinnerToTimeLabelDistance.constant = LocationSpinnerToDateLabelDistance.constant
        TimeLabel.font = LocationLabel.font
        TimeLabelToSpinnerDistance.constant = DateLabelToSpinnerDistance.constant
        TimeSpinnerHeight.constant = LocationSpinnerHeight.constant
        TimeSpinnerWidth.constant = LocationSpinnerWidth.constant
        TimeSpinnerToDurationLabelDistance.constant = LocationSpinnerToDateLabelDistance.constant
        DurationLabel.font = LocationLabel.font
        DurationLabelWidth.constant = screenSize.width * 0.25
        DurationLabelToFieldDistance.constant = DateSpinnerToTimeLabelDistance.constant
        DurationTextFieldWidth.constant = DurationLabelWidth.constant * 1.1
        DurationFieldTextHeight.constant = screenSize.height * 0.035
        DurationField.font = DurationField.font?.withSize(DurationFieldTextHeight.constant * 0.4)
        DurationField.textAlignment = .center
        DurationFieldToSavedEventsDistance.constant = TitleToLocationDistance.constant * 1.4
        SavedEventsLabel.titleLabel?.font = DurationLabel.font?.withSize(DurationFieldTextHeight.constant * 0.3)
        SavedToAdvancedDistance.constant = TimeSpinnerToDurationLabelDistance.constant * 1.2
        AdvancedOptionsLabel.titleLabel?.font = SavedEventsLabel.titleLabel?.font
        AdvancedToSubmitDistance.constant = SavedToAdvancedDistance.constant
        SubmitLabel.titleLabel?.font = SavedEventsLabel.titleLabel?.font
    }
    
    func validInputs() -> Bool {
        if (DurationField.text! == "") {
            ud.set("Empty Field(s)", forKey: "Input Error")
        } else if (Double(DurationField.text!)!) > 24.0 {
            ud.set("Duration Too Long", forKey: "Input Error")
        } else {
            return true
        }
        return false
    }
}

extension InputScreen {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {return ScrollMenuData.count}
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {return ScrollMenuData[row]}
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let ud = UserDefaults.standard
        ud.set(row, forKey: "Location Index")
        ud.set(ScrollMenuData[row], forKey: "Location")
    }
}
