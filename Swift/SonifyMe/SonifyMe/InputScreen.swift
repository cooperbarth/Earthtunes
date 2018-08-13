import UIKit
import Foundation

class InputScreen : ViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var LocationField: UIPickerView!
    @IBOutlet weak var DateField: UIDatePicker!
    @IBOutlet weak var TimeField: UIDatePicker!
    @IBOutlet weak var DurationField: UITextField!
    
    @IBAction func DateChanged(_ sender: Any) {
        ud.set(df1.string(from: DateField.date), forKey: "Date")
    }
    
    @IBAction func TimeChanged(_ sender: Any) {
        ud.set(df2.string(from: TimeField.date), forKey: "Time")
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
    
    @IBAction func AdvancedPressed(_ sender: Any) {
        ud.set(DurationField.text!, forKey: "Duration")
        performSegue(withIdentifier: "ToAdvanced", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            ud.set("3", forKey: "Duration")
        }
        LocationField.selectRow(ud.integer(forKey: "Location Index"), inComponent: 0, animated: false)
        DateField.date = df1.date(from: ud.string(forKey: "Date")!)!
        TimeField.date = df2.date(from: ud.string(forKey: "Time")!)!
        DurationField.text! = ud.string(forKey: "Duration")!
        
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
            ud.set(3, forKey: "FreqIndex")
            ud.set(0, forKey: "SCIndex")
            ud.set(1, forKey: "GCIndex")
            ud.set("10 Hz", forKey: "Frequency")
            ud.set("BHZ", forKey: "SChannel")
            ud.set("LHZ", forKey: "GChannel")
            
            saveEvents(events: [])
            
            ud.set("Set", forKey: "First")
        }
    }
    
    func showLoading() {
        ud.set(DurationField.text!, forKey: "Duration")
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Loading Screen") as! LoadingScreen
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
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
