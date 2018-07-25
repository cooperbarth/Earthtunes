import UIKit
import AVKit
import Foundation
import AudioToolbox

class ViewController: UIViewController {
    
    let url = Bundle.main.url(forResource: "sound", withExtension: "wav")
    var player : AVAudioPlayer?
    
    func addDoneButton() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.doneButtonAction))
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        //if (insertTextfieldNameHere != nil) {self.insertTextfieldNameHere.inputAccessoryView = doneToolbar}
    }
    
    @objc func doneButtonAction() {
        //if (insertTextfieldNameHere != nil) {self.insertTextfieldNameHere.resignFirstResponder}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

