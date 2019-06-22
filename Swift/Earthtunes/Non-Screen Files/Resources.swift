import Foundation
import AVKit

let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("sound.wav"))
var img : UIImage? = nil
let df1 = DateFormatter()
let df2 = DateFormatter()
var player = AVAudioPlayer()
var locationChosen : Bool = false

var locations = [Location]()
let defaultEvents: [Event] = []

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
