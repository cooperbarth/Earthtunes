import Foundation

class Event: NSObject, NSCoding {
    var location: String
    var date: String
    var time: String
    var duration: String = "2"
    var frequency: String = "10 Hz"
    var amplitude: String = "0.0001"
    var schannel: String = "BHZ"
    var gchannel: String = "LHZ"
    var s32: [Float64] = []
    var descript: String
    var favorite: Bool = false

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

    required init(Location: String, Date: String, Time: String, Descript: String) {
        location = Location
        date = Date
        time = Time
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
