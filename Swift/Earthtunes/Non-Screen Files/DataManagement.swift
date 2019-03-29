import Foundation
import AVKit

let ud = UserDefaults.standard

func saveEvents(events: [event]) {
    let archivedObject = NSKeyedArchiver.archivedData(withRootObject: events as NSArray)
    ud.set(archivedObject, forKey: "Events")
    ud.synchronize()
}

func retrieveEvents() -> [event]? {
    if let unarchivedObject = ud.object(forKey: "Events") as? NSData {
        return (NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [event])!
    }
    return nil
}

func saveFavorites(events: [event]) {
    let archivedObject = NSKeyedArchiver.archivedData(withRootObject: events as NSArray)
    ud.set(archivedObject, forKey: "Favorites")
    ud.synchronize()
}

func retrieveFavorites() -> [event]? {
    if let unarchivedObject = ud.object(forKey: "Favorites") as? NSData {
        return (NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [event])!
    }
    return nil
}

func saveFile(buff: [Float64], sample_rate: Float64) throws {
    let SAMPLE_RATE = sample_rate
    
    let outputFormatSettings = [
        AVFormatIDKey:kAudioFormatLinearPCM,
        AVLinearPCMBitDepthKey:32,
        AVLinearPCMIsFloatKey: true,
        AVLinearPCMIsBigEndianKey: false,
        AVSampleRateKey: SAMPLE_RATE,
        AVNumberOfChannelsKey: 1
        ] as [String : Any]

    var audioFile: AVAudioFile
    do {
        audioFile = try AVAudioFile(forWriting: url, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
    } catch let error as NSError {
        throw error
    }

    let bufferFormat = AVAudioFormat(settings: outputFormatSettings)
    let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(buff.count))
    for i in 0..<buff.count {outputBuffer!.floatChannelData!.pointee[i] = Float(buff[i])}
    outputBuffer?.frameLength = AVAudioFrameCount(buff.count)

    do {
        try audioFile.write(from: outputBuffer!)
    } catch {
        print("Error writing audio file")
    }
}

class event: NSObject, NSCoding {
    var location: String
    var date: String
    var time: String
    var duration: String
    var frequency: String
    var amplitude: String
    var schannel: String
    var gchannel: String
    var s32: [Float64]
    var descript: String

    required init(Location: String, Date: String, Time: String, Duration: String, Frequency: String, Amplitude: String, SChannel: String, GChannel: String, S32: [Float64], Descript: String) {
        location = Location
        date = Date
        time = Time
        duration = Duration
        frequency = Frequency
        amplitude = Amplitude
        schannel = SChannel
        gchannel = GChannel
        s32 = S32
        descript = Descript
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(location, forKey: "location")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(frequency, forKey: "frequency")
        aCoder.encode(amplitude, forKey: "amplitude")
        aCoder.encode(schannel, forKey: "schannel")
        aCoder.encode(gchannel, forKey: "gchannel")
        aCoder.encode(s32, forKey: "s32")
        aCoder.encode(descript, forKey: "descript")
    }

    required init?(coder aDecoder: NSCoder) {
        location = aDecoder.decodeObject(forKey: "location") as! String
        date = aDecoder.decodeObject(forKey: "date") as! String
        time = aDecoder.decodeObject(forKey: "time") as! String
        duration = aDecoder.decodeObject(forKey: "duration") as! String
        frequency = aDecoder.decodeObject(forKey: "frequency") as! String
        amplitude = aDecoder.decodeObject(forKey: "amplitude") as! String
        schannel = aDecoder.decodeObject(forKey: "schannel") as! String
        gchannel = aDecoder.decodeObject(forKey: "gchannel") as! String
        s32 = aDecoder.decodeObject(forKey: "s32") as! [Float64]
        descript = aDecoder.decodeObject(forKey: "descript") as! String
    }
}
