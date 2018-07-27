import UIKit
import AVKit
import Foundation
import AudioToolbox

class InputScreen : ViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var LocationField: UIPickerView!
    var LocationValue : String = "Select Location:"
    @IBOutlet weak var DateField: UITextField!
    @IBOutlet weak var TimeField: UITextField!
    @IBOutlet weak var DurationField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ((segue.destination as? LoadingScreen) != nil) {
            let loadingScreen = segue.destination as? LoadingScreen
            loadingScreen?.inputLocation = LocationValue
            loadingScreen?.inputDate = DateField.text!
            loadingScreen?.inputTime = TimeField.text!
            loadingScreen?.inputDuration = DurationField.text!
        }
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
    
    
    
    //Scroll Menu Setup
    let ScrollMenuData = ["Select Location:",
                          "Ryerson (IL,USA)",
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
        LocationValue = ScrollMenuData[row]
    }
    
    func validInputs() -> Bool {
        if (LocationValue == "Select Location:" || DateField.text == "" || TimeField.text == "" || TimeField.text == "") {return false}
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DateField.text! = "2017-07-07"
        TimeField.text! = "00:00"
        DurationField.text! = "6"
        
        addDoneButton()
        
        self.LocationField.delegate = self
        self.LocationField.dataSource = self
    }
}
