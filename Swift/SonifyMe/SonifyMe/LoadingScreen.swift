import UIKit
import AVKit
import Foundation
import AudioToolbox

class LoadingScreen : ViewController {
    var inputLocation = ""
    var inputDate = ""
    var inputTime = ""
    var inputDuration = ""
    var graphData : [Float64] = [Float64]()
    var mxs : Float64 = 0.0
    var passTitle : String = "Seismic Data"
    var passImgURL : String = ""
    var fsps : Double = 0.0
    var bandsHZ : Double = 0.0
    
    @IBOutlet weak var LoadingLabel: UILabel!
    @IBOutlet weak var Spinner: UIActivityIndicatorView!
    
    func getSoundAndGraph(locate:String, date:String, time:String, duration:String, AF:String, FA:String) -> [Float64] {
        let duration = String(Float64(duration)! * 3600)
        let time = time + ":00"
        
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
        passTitle = locate
        
        let graphType = net + "&sta=" + station + "&loc=" + location + "&cha=LHZ"
        let soundType = net + "&sta=" + station + "&loc=" + location + "&cha=BHZ"
        let when = "&starttime=" + date + "T" + time + "&duration=" + duration
        
        let graphUrl = "https://service.iris.edu/irisws/timeseries/1/query?net=" + graphType + when + "&demean=true&hp=0.001&scale=auto&output=ascii1"
        var dfGraph = ""
        do {
            dfGraph = try String(contentsOf: URL(string: graphUrl)!)
        } catch {
            print("Invalid URL for Graph")
        }
        
        let soundUrl = "https://service.iris.edu/irisws/timeseries/1/query?net=" + soundType + when + "&demean=true&hp=0.001&scale=auto&output=ascii1"
        var dfSound = ""
        do {
            dfSound = try String(contentsOf: URL(string: soundUrl)!)
        } catch {
            print("Invalid URL for Graph")
        }
        
        let g32 = processData(data: dfGraph, AF: AF, FA: FA)
        
        let s32 = processData(data: dfSound, AF: AF, FA: FA)
        let ssps = bandsHZ * fsps
        saveFile(buff: s32, sample_rate: ssps)
        
        return g32
    }
    
    func processData(data: String, AF: String, FA: String) -> [Float64] {
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
                                                "50 Hz" : 160.0]
        let optbandsHZ = frequencies[AF]
        if (optbandsHZ == nil) {
            bandsHZ = 400.0
        } else {
            bandsHZ = optbandsHZ!
        }
        
        var fixedamp: Float64
        if (FA == "") {
            fixedamp = 0.0001
        } else {
            fixedamp = Float64(FA)!
        }
        
        let realduration = (tot!/fsps)/3600
        var hours = [Float64]()
        var marker = 0.0
        let increment = realduration / tot!
        while (marker < realduration) {
            hours.append(marker)
            marker = marker + increment
        }
        
        mxs = 1.01*Double(Float64((2^31))*atan(maxAmp/fixedamp)/halfpi)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ((segue.destination as? DisplayScreen) != nil) {
            let displayScreen = segue.destination as? DisplayScreen
            displayScreen?.data = graphData
            displayScreen?.yMax = mxs
            displayScreen?.yMin = -mxs
            displayScreen?.TitleText = passTitle
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        graphData = self.getSoundAndGraph(locate: inputLocation, date: inputDate, time: inputTime, duration: inputDuration, AF: "", FA: "")
        performSegue(withIdentifier: "ToDisplay", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingLabel.text! = "Loading Data From " + inputLocation + "..."
    }
}
