import UIKit
import AVKit
import Foundation
import AudioToolbox

/*
 Things to Implement:
 -Aesthetics
 -Make rate/playback speed work
 -Graph Axes
 -Suggested Events Screen
 -Fix formatting for non-iPhone 8
 -Put tips as to what the advanced options actually do
 -Figure out time zone stuff? (2 options: local and UTC?)
 -Save images and sound to phone
 -FAQ button
 -Send Feedback
 */

class ViewController: UIViewController, UITextFieldDelegate {
    let ud = UserDefaults.standard
    let url = Bundle.main.url(forResource: "sound", withExtension: "wav")
    let imgUrl = Bundle.main.url(forResource: "img", withExtension: "jpeg")
    var player : AVAudioPlayer?
    let df1 = DateFormatter()
    let df2 = DateFormatter()
    var count = 0
    
    func saveEvents(events: [event]) {
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: events as NSArray)
        ud.set(archivedObject, forKey: "Events")
        ud.synchronize()
    }
    
    func retrieveEvents() -> [event]? {
        if let unarchivedObject = ud.object(forKey: "Events") as? NSData {
            return (NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [event])!
        }
        print("Failed to retrieve data")
        return nil
    }
    
    func showPopup(name: String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    func showInputError() {
        showPopup(name: "Input Error")
    }

    func isNumber(num: String) -> Bool {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.view.removeFromSuperview()
            }
        });
    }
    
    let ScrollMenuData = ["Ryerson (IL,USA)",
                          "Yellowstone (WY,USA)",
                          "Anchorage (AK,USA)",
                          "Paris, France",
                          "Inuyama, Japan",
                          "Cachiyuyo, Chile",
                          "Addis Ababa, Ethiopia",
                          "Ar Rayn, Saudi Arabia",
                          "Antarctica"]
    var locationChosen : Bool = false
}

class event: NSObject, NSCoding {
    var location: String
    var date: String
    var time: String
    var duration: String
    var frequency: String
    var amplitude: String
    var rate: String
    var hp: String
    var schannel: String
    var gchannel: String
    var g32: [Float64]
    var s32: [Float64]
    
    required init(Location: String, Date: String, Time: String, Duration: String, Frequency: String, Amplitude: String, Rate: String, HP: String, SChannel: String, GChannel: String, G32: [Float64], S32: [Float64]) {
        location = Location
        date = Date
        time = Time
        duration = Duration
        frequency = Frequency
        amplitude = Amplitude
        rate = Rate
        hp = HP
        schannel = SChannel
        gchannel = GChannel
        g32 = G32
        s32 = S32
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(location, forKey: "location")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(frequency, forKey: "frequency")
        aCoder.encode(amplitude, forKey: "amplitude")
        aCoder.encode(rate, forKey: "rate")
        aCoder.encode(hp, forKey: "hp")
        aCoder.encode(schannel, forKey: "schannel")
        aCoder.encode(gchannel, forKey: "gchannel")
        aCoder.encode(g32, forKey: "g32")
        aCoder.encode(s32, forKey: "s32")
    }
    
    required init?(coder aDecoder: NSCoder) {
        location = aDecoder.decodeObject(forKey: "location") as! String
        date = aDecoder.decodeObject(forKey: "date") as! String
        time = aDecoder.decodeObject(forKey: "time") as! String
        duration = aDecoder.decodeObject(forKey: "duration") as! String
        frequency = aDecoder.decodeObject(forKey: "frequency") as! String
        amplitude = aDecoder.decodeObject(forKey: "amplitude") as! String
        rate = aDecoder.decodeObject(forKey: "rate") as! String
        hp = aDecoder.decodeObject(forKey: "hp") as! String
        schannel = aDecoder.decodeObject(forKey: "schannel") as! String
        gchannel = aDecoder.decodeObject(forKey: "gchannel") as! String
        g32 = aDecoder.decodeObject(forKey: "g32") as! [Float64]
        s32 = aDecoder.decodeObject(forKey: "s32") as! [Float64]
    }
}

