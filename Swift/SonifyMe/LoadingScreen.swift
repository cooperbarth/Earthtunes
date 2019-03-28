import UIKit
import AVKit
import Foundation
import AudioToolbox

class LoadingScreen : ViewController {
    @IBOutlet weak var LoadingLabel: UILabel!

    var locate = UserDefaults.standard.string(forKey: "Location")!
    let date = UserDefaults.standard.string(forKey: "Date")!
    let time = UserDefaults.standard.string(forKey: "Time")! + ":00"
    let duration = String(Float64(UserDefaults.standard.string(forKey: "Duration")!)! * 3600)
    let inputFreq = UserDefaults.standard.string(forKey: "Frequency")!
    let inputAmp = UserDefaults.standard.string(forKey: "Amplitude")!
    let inputRate = UserDefaults.standard.string(forKey: "Rate")!
    let inputSChannel = UserDefaults.standard.string(forKey: "SChannel")!
    let inputGChannel = UserDefaults.standard.string(forKey: "GChannel")!
    var fsps : Double = 0.0
    var bandsHZ : Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeViewAppear()
        self.showAnimate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getSoundAndGraph()
    }
}

extension LoadingScreen {
    func makeViewAppear() {
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        LoadingLabel.text! = "Loading Data From \n" + ud.string(forKey: "Location")!
    }
}

extension LoadingScreen {
    func getSoundAndGraph() {
        let station: String
        let net: String
        let location: String
        if locations.keys.contains(self.locate) {
            (station, net, location) = locations[self.locate]!
        } else {
            print("Location not in set")
            showError404()
            return
        }

        let graphType = net + "&sta=" + station + "&loc=" + location + "&cha=" + inputGChannel
        let soundType = net + "&sta=" + station + "&loc=" + location + "&cha=" + inputSChannel
        let when = "&starttime=" + date + "T" + time + "&duration=" + duration
        let soundUrl = "https://service.iris.edu/irisws/timeseries/1/query?net=" + soundType + when + "&demean=true&scale=auto&output=ascii1"
        let graphUrl = "https://service.iris.edu/irisws/timeseries/1/query?net=" + graphType + when + "&demean=true&scale=auto&output=plot"
        ud.set(graphUrl, forKey: "GraphURL")

        let ssps = self.bandsHZ * self.fsps
        let prevData = checkRepeats()
        if (prevData != nil) {
            let s32 = prevData?.s32
            saveFile(buff: s32!, sample_rate: ssps)
            ud.set(s32, forKey: "Data")
        } else {
            do {
                let dfSound = try String(contentsOf: URL(string: soundUrl)!)
                let s32 = processData(data: dfSound)
                saveFile(buff: s32, sample_rate: ssps)
                ud.set(s32, forKey: "Data")
                saveData(s32: s32)
            } catch {
                showError404()
                return
            }
        }
        ud.set(self.locate, forKey: "Title")
        setUpGraph()
        performSegue(withIdentifier: "ToDisplay", sender: self)
    }

    func processData(data: String) -> [Float64] {
        let dflines = data.split(separator: "\n")
        let head = dflines[0]
        self.fsps = Float64(head.split(separator: " ")[4])!
        var tot = Float64(head.split(separator: " ")[2])!
        var sound = [Float64]()
        var maxAmp = 0.0
        for i in 1..<dflines.count {
            if (isNumber(num: String(dflines[i]))) {
                let f = Float64(dflines[i])!
                sound.append(f)
                maxAmp = max(maxAmp, abs(f))
            } else {
                print(dflines[i].split(separator: " "))
                let curr = Float64(dflines[i].split(separator: " ")[2])!
                tot += curr
            }
        }

        let frequencies : [String : Float64] = ["0.1 Hz" : 64000.0,
                                                "0.5 Hz" : 16000.0,
                                                "5 Hz" : 1600.0,
                                                "10 Hz" : 800.0,
                                                "20 Hz" : 400.0,
                                                "50 Hz" : 160.0]
        self.bandsHZ = frequencies[self.inputFreq]!

        let fixedamp = Float64(self.inputAmp)!
        let realduration = (tot/self.fsps)/3600
        var hours = [Float64]()
        var marker = 0.0
        let increment = realduration / tot
        while (marker < realduration) {
            hours.append(marker)
            marker += increment
        }

        let multiplier = Float64(2^31) / (0.5 * Double.pi)
        ud.set(atan(maxAmp/fixedamp) * multiplier, forKey: "Max")
        var s32 = [Float64]()
        for ii in 0..<sound.count {
            s32.append(atan(sound[ii]/fixedamp) * multiplier)
        }
        return s32
    }

    func showError404() {
        let alertController = UIAlertController(title: "Error 404", message: error404Text, preferredStyle: .alert)
        let returnAction = UIAlertAction(title: "Return", style: .default) { (_) -> Void in
            UIView.setAnimationsEnabled(false)
            self.performSegue(withIdentifier: "Error404", sender: self)
        }
        alertController.addAction(returnAction)
        present(alertController, animated: true, completion: nil)
    }

    func checkRepeats() -> event? {
        for e in retrieveEvents()! {
            if (e.location == locate && e.date == date && e.time == time && e.duration == duration && e.frequency == inputFreq && e.amplitude == inputAmp && e.schannel == inputSChannel && e.gchannel == inputGChannel) {
                LoadingLabel.text! = "Loading Previously \nSaved Data From \n" + ud.string(forKey: "Location")!
                return e
            }
        }
        return nil
    }

    func saveData(s32: [Float64]) {
        let newEvent = event(Location: locate, Date: date, Time: time, Duration: duration, Frequency: inputFreq, Amplitude: inputAmp, SChannel: inputSChannel, GChannel: inputGChannel, S32: s32, Descript: "")
        var newEvents = retrieveEvents()
        newEvents!.append(newEvent)
        saveEvents(events: newEvents!)
    }
}

extension LoadingScreen {
    func setUpGraph() {
        do {
            let graphURL = ud.string(forKey: "GraphURL")
            let data = try Data(contentsOf: URL(string: graphURL!)!)
            img = UIImage(data: data)
        } catch {
            print("Error: Image Not Found")
        }
    }
}
