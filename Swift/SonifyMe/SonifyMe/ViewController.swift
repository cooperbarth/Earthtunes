import UIKit
import AVKit
import Foundation
import AudioToolbox

/*
 Things to Implement:
 -Invalid URL dates/stations/whatever
 -Aesthetics
 -Graph Axes
 -Suggestion Screen
 -Repeated inputs/requests
 -Fix for non-iPhone 8
 -Put tips as to what the advanced options actually do
 */

class ViewController: UIViewController, UITextFieldDelegate {
    let ud = UserDefaults.standard
    let url = Bundle.main.url(forResource: "sound", withExtension: "wav")
    let imgUrl = Bundle.main.url(forResource: "img", withExtension: "jpeg")
    var player : AVAudioPlayer?
    let df1 = DateFormatter()
    let df2 = DateFormatter()
    var count = 0

    func isNumber(num:String) -> Bool {
        if (Float(num) != nil) {return true}
        var theNum = ""
        if (num[num.startIndex] == "-") {
            theNum = String(num[num.index(num.startIndex, offsetBy: 1)..<num.endIndex])
        } else {
            theNum = num
        }
        let numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        if (!numbers.contains(String(theNum[num.index(num.startIndex, offsetBy: 0)]))) {return false}
        let secondChar = String(theNum[num.index(num.startIndex, offsetBy: 1)])
        if (secondChar != "." && secondChar != "e") {return false}
        let lastChar = String(theNum[num.index(num.startIndex, offsetBy: num.count - 1)])
        if (!isNumber(num: lastChar)) {return false}
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // return NO to not change text
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            var decimalCount = 0
            for character in textField.text! {
                if character == "." {decimalCount += 1}}
            if decimalCount == 1 {return false}
            return true
        default:
            if string.count == 0 {return true}
            return false
        }
    }
    
    func initDoneButton() -> UIView {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        return doneToolbar
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

