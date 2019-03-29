import Foundation
import AVKit

let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("sound.wav"))
var img : UIImage? = nil
let df1 = DateFormatter()
let df2 = DateFormatter()
var player = AVAudioPlayer()
var locationChosen : Bool = false

let ScrollMenuData = ["Ryerson (IL,USA)",
                      "Yellowstone (WY,USA)",
                      "Anchorage (AK,USA)",
                      "Paris, France",
                      "Inuyama, Japan",
                      "Cachiyuyo, Chile",
                      "Addis Ababa, Ethiopia",
                      "Ar Rayn, Saudi Arabia",
                      "Antarctica"]

let defaultEvents: [Event] = [
    Event(Location: "Ryerson (IL,USA)", Date: "2016-11-07", Time: "00:30", Descript: eventOneDescription),
    Event(Location: "Ryerson (IL,USA)", Date: "2017-06-02", Time: "00:00", Descript: eventTwoDescription),
    Event(Location: "Ryerson (IL,USA)", Date: "2017-07-06", Time: "05:30", Descript: eventThreeDescription),
    Event(Location: "Ryerson (IL,USA)", Date: "2018-05-04", Time: "22:00", Descript: eventFourDescription),
    Event(Location: "Ryerson (IL,USA)", Date: "2018-07-08", Time: "15:30", Descript: eventFiveDescription),
    Event(Location: "Ryerson (IL,USA)", Date: "2018-07-24", Time: "13:00", Descript: eventSixDescription)
]

let locations: [String: (String, String, String)] = [
    "Ryerson (IL,USA)": ("L44A", "TA", "--"),
    "Yellowstone (WY,USA)": ("H17A", "TA", "--"),
    "Anchorage (AK,USA)": ("SSN", "AK", "--"),
    "Paris, France": ("CLF", "G", "00"),
    "Inuyama, Japan": ("INU", "G", "00"),
    "Cachiyuyo, Chile": ("LCO", "IU", "10"),
    "Addis Ababa, Ethiopia": ("FURI", "IU", "00"),
    "Ar Rayn, Saudi Arabia": ("RAYN", "II", "10"),
    "Antarctica": ("CASY", "IU", "10")
]

func getLocation(location: String) -> (String, String, String) {
    switch location {
    case "Yellowstone (WY,USA)":
        return ("H17A", "TA", "--")
    case "Anchorage (AK,USA)":
        return ("SSN", "AK", "--")
    case "Paris, France":
        return ("CLF", "G", "00")
    case "Inuyama, Japan":
        return ("INU", "G", "00")
    case "Cachiyuyo, Chile":
        return ("LCO", "IU", "10")
    case "Addis Ababa, Ethiopia":
        return ("FURI", "IU", "00")
    case "Ar Rayn, Saudi Arabia":
        return ("RAYN", "II", "10")
    case "Antarctica":
        return ("CASY", "IU", "10")
    default:
        return ("L44A", "TA", "--")
    }
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
