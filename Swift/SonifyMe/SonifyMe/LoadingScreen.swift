import UIKit
import AVKit
import Foundation
import AudioToolbox

class LoadingScreen : ViewController {
    @IBOutlet weak var LoadingLabel: UILabel!
    @IBOutlet weak var Spinner: UIActivityIndicatorView!
    
    let locate = UserDefaults.standard.string(forKey: "Location")!
    let date = UserDefaults.standard.string(forKey: "Date")!
    let time = UserDefaults.standard.string(forKey: "Time")! + ":00"
    let duration = String(Float64(UserDefaults.standard.string(forKey: "Duration")!)! * 3600)
    
    let inputFreq = UserDefaults.standard.string(forKey: "Frequency")!
    let inputAmp = UserDefaults.standard.string(forKey: "Amplitude")!
    let inputRate = UserDefaults.standard.string(forKey: "Rate")! //doesn't do anything yet
    let inputHP = UserDefaults.standard.string(forKey: "HP")!
    let inputSChannel = UserDefaults.standard.string(forKey: "SChannel")!
    let inputGChannel = UserDefaults.standard.string(forKey: "GChannel")!
    
    var fsps : Double = 0.0
    var bandsHZ : Double = 0.0
    
    func getSoundAndGraph() {
        var station = ""
        var net = ""
        var location = ""
        switch locate {
            case "Yellowstone (WY,USA)":
                station = "H17A"
                net = "TA"
                location = "--"
                break
            case "Anchorage (AK,USA)":
                station = "SSN"
                net = "AK"
                location = "--"
                break
            case "Paris, France":
                station = "CLF"
                net = "G"
                location = "00"
                break
            case "Inuyama, Japan":
                station = "INU"
                net = "G"
                location = "00"
                break
            case "Cachiyuyo, Chile":
                station = "LCO"
                net = "IU"
                location = "10"
                break
            case "Addis Ababa, Ethiopia":
                station = "FURI"
                net = "IU"
                location = "00"
                break
            case "Ar Rayn, Saudi Arabia":
                station = "RAYN"
                net = "II"
                location = "10"
                break
            case "Antarctica":
                station = "CASY"
                net = "IU"
                location = "10"
                break
            default:
                station = "L44A"
                net = "TA"
                location = "--"
                print("Defaulting to Ryerson Station...")
                break
        }
        ud.set(locate, forKey: "Title")
        
        let graphType = net + "&sta=" + station + "&loc=" + location + "&cha=" + inputGChannel
        let soundType = net + "&sta=" + station + "&loc=" + location + "&cha=" + inputSChannel
        let when = "&starttime=" + date + "T" + time + "&duration=" + duration
        
        let graphUrl = "https://service.iris.edu/irisws/timeseries/1/query?net=" + graphType + when + "&demean=true&hp=" + inputHP + "&scale=auto&output=ascii1"
        
        let soundUrl = "https://service.iris.edu/irisws/timeseries/1/query?net=" + soundType + when + "&demean=true&hp=" + inputHP + "&scale=auto&output=ascii1"
        var dfSound = ""
        do {
            dfSound = try String(contentsOf: URL(string: soundUrl)!)
        } catch {
            print("Invalid URL for Sound")
        }
        
        let s32 = processData(data: dfSound)
        let ssps = bandsHZ * fsps
        saveFile(buff: s32, sample_rate: ssps)
        
        if (graphUrl != soundUrl) {
            var dfGraph : String = ""
            do {
                 dfGraph = try String(contentsOf: URL(string: graphUrl)!)
            } catch {
                print("Invalid URL for Graph")
            }
            let g32 = processData(data: dfGraph)
            ud.set(g32, forKey: "Data")
        } else {
            ud.set(s32, forKey: "Data")
        }
    }
    
    func processData(data: String) -> [Float64] {
        let halfpi = 0.5*Double.pi
        let dflines = data.split(separator: "\n")
        let head = dflines[0]
        fsps = Float64(head.split(separator: " ")[4])!
        var tot = Float64(head.split(separator: " ")[2])
        var sound = [Float64]()
        var maxAmp = 0.0
        for i in 1..<dflines.count {
            if (self.isNumber(num: String(dflines[i]))) {
                let f = Float64(dflines[i])
                sound.append(f!)
                maxAmp = max(maxAmp, abs(f!))
            } else {
                print(dflines[i].split(separator: " "))
                let curr = Float64(dflines[i].split(separator: " ")[2])!
                tot = tot! + curr
            }
        }
        
        let frequencies : [String : Float64] = ["0.1 Hz" : 64000.0,
                                                "0.5 Hz" : 16000.0,
                                                "5 Hz" : 1600.0,
                                                "10 Hz" : 800.0,
                                                "20 Hz" : 400.0,
                                                "50 Hz" : 160.0]
        bandsHZ = frequencies[inputFreq]!
        
        let fixedamp = Float64(inputAmp)!
        let realduration = (tot!/fsps)/3600
        var hours = [Float64]()
        var marker = 0.0
        let increment = realduration / tot!
        while (marker < realduration) {
            hours.append(marker)
            marker = marker + increment
        }
        
        let mxs = 1.01*Double(Float64((2^31))*atan(maxAmp/fixedamp)/halfpi)
        ud.set(mxs, forKey: "Max")
        var s32 = [Float64]()
        for ii in 0..<sound.count {
            s32.append(Float64((2^31))*atan(sound[ii]/fixedamp)/halfpi)
        }
        return s32
    }
    
    func saveFile(buff: [Float64], sample_rate: Float64) {
        let SAMPLE_RATE = sample_rate
        
        let outputFormatSettings = [
            AVFormatIDKey:kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey:32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVSampleRateKey: SAMPLE_RATE,
            AVNumberOfChannelsKey: 1
            ] as [String : Any]
        
        let audioFile = try? AVAudioFile(forWriting: url!, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
        
        let bufferFormat = AVAudioFormat(settings: outputFormatSettings)
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(buff.count))
        for i in 0..<buff.count {outputBuffer!.floatChannelData!.pointee[i] = Float(buff[i])}
        outputBuffer?.frameLength = AVAudioFrameCount(buff.count)
        
        do {
            try audioFile?.write(from: outputBuffer!)
        } catch {
            print("Error writing audio file")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.getSoundAndGraph()
        performSegue(withIdentifier: "ToDisplay", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingLabel.text! = "Loading Data From " + ud.string(forKey: "Location")! + "..."
    }
}
