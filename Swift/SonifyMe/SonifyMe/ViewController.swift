import UIKit
import AVKit
import Foundation
import AudioToolbox

/*
 Things to Implement:
 -Make user be able to save to and remove from "Suggestion Screen"
    -Star icon on display screen to save/unsave event
 -Aesthetics
 -More Explanation Screens
 -Clear cache of old data
 -Suggested Events Screen
 -Make rate/playback speed work
 -Graph Axes
 -Fix formatting for non-iPhone 8
 -Figure out time zone stuff? (2 options: local and UTC?)
 -Save images and sound to phone
 -FAQ button
 -Send Feedback
 */

class ViewController: UIViewController, UITextFieldDelegate {
    let ud = UserDefaults.standard
    
    func showPopup(name: String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
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
}
