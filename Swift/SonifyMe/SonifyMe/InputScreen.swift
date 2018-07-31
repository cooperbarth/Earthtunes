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
        if (validInputs()) {
            performSegue(withIdentifier: "ToLoading", sender: self)
        } else {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Input Error") as! InputErrorScreen
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        }
    }
    
    @IBAction func AdvancedPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToAdvanced", sender: self)
    }
    
    //Adding "Done" button to text fields
    func addDoneButton() {
        let doneToolbar = initDoneButton()
        if(DurationField != nil) {self.DurationField.inputAccessoryView = doneToolbar}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationField.delegate = self
        LocationField.dataSource = self
        DurationField.delegate = self
        
        DateField.maximumDate = Date()
        df1.dateFormat = "YYYY-MM-dd"
        df2.dateFormat = "HH:mm"
        
        addDoneButton()
        
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ud.set(DurationField.text!, forKey: "Duration")
    }
    
    func validInputs() -> Bool {
        if (DurationField.text! == "") {return false}
        if (Double(DurationField.text!)!) > 24.0 {return false}
        return true
    }
    
    //Location Picker Setup
    let ScrollMenuData = ["Ryerson (IL,USA)",
                          "Yellowstone (WY,USA)",
                          "Anchorage (AK,USA)",
                          "Paris, France",
                          "Inuyama, Japan",
                          "Cachiyuyo, Chile",
                          "Addis Ababa, Ethiopia",
                          "Ar Rayn, Saudi Arabia",
                          "Antarctica"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {return ScrollMenuData.count}
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {return ScrollMenuData[row]}
    
    var locationChosen : Bool = false
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let ud = UserDefaults.standard
        ud.set(row, forKey: "Location Index")
        ud.set(ScrollMenuData[row], forKey: "Location")
    }
}
