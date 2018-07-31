import UIKit
import Foundation

class InputScreen : ViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var LocationField: UIPickerView!
    @IBOutlet weak var DateField: UIDatePicker!
    @IBOutlet weak var TimeField: UITextField!
    @IBOutlet weak var DurationField: UITextField!
    
    @IBAction func DateChanged(_ sender: Any) {
        ud.set(df.string(from: DateField.date), forKey: "Date")
        print("hello")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ud.set(TimeField.text!, forKey: "Time")
        ud.set(DurationField.text!, forKey: "Duration")
    }
    
    @IBAction func AdvancedPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToAdvanced", sender: self)
    }
    
    @IBAction func ButtonPressed(_ sender: Any) {
        if (validInputs()) {
            performSegue(withIdentifier: "ToLoading", sender: self)
        }
    }
    
    //Adding "Done" button to text fields
    func addDoneButton() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        if(DurationField != nil) {self.DurationField.inputAccessoryView = doneToolbar}
    }
    
    @objc func doneButtonAction() {
        if (DurationField != nil) {
            view.endEditing(true)
        }
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
    
    //Date Picker Setup
    override func validInputs() -> Bool {
        if (TimeField.text == "" || DurationField.text == "") {return false}
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationField.delegate = self
        LocationField.dataSource = self
        
        DateField.maximumDate = Date()
        df.dateFormat = "YYYY-MM-dd"
        
        addDoneButton()
        
        if (ud.string(forKey: "Location") == nil) {
            ud.set("Ryerson (IL,USA)", forKey: "Location")
        }
        if (ud.string(forKey: "Date") == nil) {
            ud.set(df.string(from: Date()), forKey: "Date")
        }
        if (ud.string(forKey: "Time") == nil) {
            ud.set("00:00", forKey: "Time")
        }
        if (ud.string(forKey: "Duration") == nil) {
            ud.set("3", forKey: "Duration")
        }
        LocationField.selectRow(ud.integer(forKey: "Location Index"), inComponent: 0, animated: false)
        DateField.date = df.date(from: ud.string(forKey: "Date")!)!
        TimeField.text! = ud.string(forKey: "Time")!
        DurationField.text! = ud.string(forKey: "Duration")!
    }
}
