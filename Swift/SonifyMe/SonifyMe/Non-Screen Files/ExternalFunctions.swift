import Foundation
import AVKit

let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("sound.wav"))
let imgUrl = URL(fileURLWithPath: NSTemporaryDirectory().appending("graph.jpeg"))
let df1 = DateFormatter()
let df2 = DateFormatter()
var player : AVAudioPlayer?
var count = 0

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

let defaultEvents: [event] = [
    event(Location: "Ryerson (IL,USA)", Date: "2016-11-07", Time: "00:30", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", G32: [], S32: [], Descript: "Magnitude 5.0 Earthquake in Oklahoma"),
    event(Location: "Ryerson (IL,USA)", Date: "2017-06-02", Time: "00:00", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", G32: [], S32: [], Descript: "Sunny Day at Ryerson Station"),
    event(Location: "Ryerson (IL,USA)", Date: "2017-07-06", Time: "05:30", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", G32: [], S32: [], Descript: "Magnitude 5.8 Earthquake in Montana"),
    event(Location: "Ryerson (IL,USA)", Date: "2018-05-04", Time: "22:00", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", G32: [], S32: [], Descript: "Magnitude 5.4 Earthquake in Hawaii"),
    event(Location: "Ryerson (IL,USA)", Date: "2018-07-08", Time: "15:30", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", G32: [], S32: [], Descript: "Students went to Ryerson station and jumped on the ground near the seismometer. See if you can find a frequency to hear it!"),
    event(Location: "Ryerson (IL,USA)", Date: "2018-07-24", Time: "13:00", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", G32: [], S32: [], Descript: "Thunderstorm at Ryerson Station")
]

let soundExplain = "Controls the channel from which the data for the sound is retrieved. BHZ will retrieve more data points than LHZ, but will take much longer to load."
let graphExplain = "Controls the channel from which the data for the graph is retrieved. BHZ will retrieve more data points than LHZ, but will take much longer to load."

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
