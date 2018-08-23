import Foundation
import AVKit

let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("sound.wav"))
var img : UIImage? = nil
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
    event(Location: "Ryerson (IL,USA)", Date: "2016-11-07", Time: "00:30", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", S32: [], Descript: "Magnitude 5.0 Earthquake in Oklahoma"),
    event(Location: "Ryerson (IL,USA)", Date: "2017-06-02", Time: "00:00", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", S32: [], Descript: "Sunny Day at Ryerson Station"),
    event(Location: "Ryerson (IL,USA)", Date: "2017-07-06", Time: "05:30", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", S32: [], Descript: "Magnitude 5.8 Earthquake in Montana"),
    event(Location: "Ryerson (IL,USA)", Date: "2018-05-04", Time: "22:00", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", S32: [], Descript: "Magnitude 5.4 Earthquake in Hawaii"),
    event(Location: "Ryerson (IL,USA)", Date: "2018-07-08", Time: "15:30", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", S32: [], Descript: "Students went to Ryerson station and jumped on the ground near the seismometer. See if you can find a frequency at which you can hear it!"),
    event(Location: "Ryerson (IL,USA)", Date: "2018-07-24", Time: "13:00", Duration: "2", Frequency: "10 Hz", Amplitude: "0.0001", SChannel: "BHZ", GChannel: "LHZ", S32: [], Descript: "Thunderstorm at Ryerson Station")
]

let freqText = "\n0.1/0.5 Hz - The area where microseisms occur. Most sound will simply sound like white noise,  but earthquakes are very audible.  5 Hz - Great for highlighting earthquake sounds and provides for quick sound files.  10 Hz - The best compromise between 5 Hz and 20 Hz. This is the default setting for the app.  20 Hz - Great for birds-in-the-woods sounds. Sound duration is usually manageable.  50 Hz - Best for listening to small jumps, but activity is usually very quick and easy to miss."
let ampText = "Controls the volume of the output sound. Higher values will make the sound quieter."
let channelText1 = "Controls the channel from which the data for the "
let channelText2 = " is retrieved. BHZ will retrieve more data points than LHZ, but will take much longer to load."
let saveGraphText = "To save your graphs, open Settings and allow Earthtunes to access your Photos Library"
let clearCacheText = "This action will erase all previous searches from memory. Proceed?"
let deleteEventText = "Are you sure you want to delete the saved event?"
let error404Text = "The requested URL could not be found."
let suggestionIntroText = "This is the saved events screen, where events saved by the user are shown. Long-pressing on an event will show its editable description, and swiping left will delete it from the list."
let ringerText = "Make sure your ringer is turned on to hear the sound!"

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
