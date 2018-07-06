import Foundation
import Darwin

func earthtunes() {
    let halfpi = 0.5 * Double.pi

    //soundname = "midewin"
    //station = "M44A"
    //net = "N4"
    //location = "--"
    //channel = "HHZ"

    let soundname = "ryerson"
    let station = "L44A"
    let net = "TA"
    let location = "--"
    let channel = "BHZ"

    //soundname = "yellowstone"
    //station = "H17A"
    //net = "TA"
    //location = "--"
    //channel = "BHZ"

    // use a fixed amplitude scale for seismograms with physical (m/s) y-axis units (use "scale=AUTO" in web request)
    // An arctan() function is used to keep sound from overshooting and destroying speakers (the IRIS audio service calls this "compression" -- I guess!)
    // enter the signal level (in physical units (m/s)) to which you want sound to scale quasi-linearly (about a third of the expected maximum signal)
    let fixedamp = Double(5) * Darwin.pow(Double(10), Double(-5))

    // yesterday:
    let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    print ("Getting yesterday's Ryerson data: " ,date)

    // a specific random day (with 2 thunderstorms):
    // date = "2016-07-24"

    // Alaska M6.2 & Alaska M6.2
    //date = "2017-05-01"

    // M5.8 Montana and M6.5 Philippines
    //date = "2017-07-06"

    // Oklahoma M4.2
    //date = "2017-07-14"

    let time = "00:00:00"

    let duration = "86400"   //  in seconds = 24 hours
    //duration = "21600"  // 6 hours

    // 6 different time series acceleration factors ("stretch" factors in the frequency domain).
    // only one of them is used in line 101.
    let bandstupto50Hz = 160
    let bandstupto20Hz = 400
    let bandstupto10Hz = 800
    let bandstupto5Hz = 1600
    let bandstuptohalfHz = 16000
    let bandstuptotenthHz = 64000
    //--------------------------------------------------

    // request data from IRIS" timeseries web service, and store in folder "IRISfiles" (make sure it exists) for ipotential repeat use.
    let type = net + "&sta=" + station + "&loc=" + location + "&cha=" + channel
    let when = "&starttime=" + date + "T" + time + "&duration=" + duration
    let url = "http://service.iris.edu/irisws/timeseries/1/query?net=" + type + when + "&demean=true&scale=auto&output=ascii1"
    let sfn = "IRISfiles/" + station + "." + net + ".." + channel + "." + date + "." + duration + ".rm.scale-AUTO.txt"
    print("Requesting ",url)
    print("Saved in ",sfn)

    
    var dflines : [String]
    if (path.isfile(sfn)) {
        print("reading previously requested data from saved file...")
        let rsfn = open(sfn,"r")
        let df = rsfn.read()
        dflines = df.split("\n")
    } else {
        print("requesting data from IRIS...please be patient...")
        let ws = urllib2.urlopen(url)
        print("loading data ...")
        let df = ws.read()
        print("processing data...")
        dflines = df.split("\n")
        let wsfn = open(sfn,"w")
        wsfn.write(df)
    }

    let head = dflines[0]
    var sound1 = Array(dflines[1...])
    var sound : [Double] = []
    var count = 0
    while (count < sound1.count) {
        sound.append(((sound1[count]) as NSString).doubleValue)
        count = count + 1
    }
    
    // sampling rate in data:
    let fsps = Double(head.split(separator: " ")[4])
    // total number of samples in data:
    let tot = Double(head.split(separator: " ")[2])
    // duration of data (in hours):
    let realduration = (tot!/fsps!)/3600
    var hours : [Double] = []
    var curr = Double(0)
    while (curr < realduration) {
        hours.append(curr)
        curr = curr + (realduration / tot!)
    }
    
    let soundduration = tot! / (fsps! * Double(bandstupto20Hz))

    var mxs = -Double.infinity
    var mns = Double.infinity
    for number in sound {
        if (number < mns) {
            mns = number
        }
        if (number > mxs) {
            mxs = number
        }
    }
    mxs = 1.01 * mxs
    mns = 1.01 * mns

    // use fixed_amplitude:
    let scaledsound = Darwin.pow(2, 31) * atan(sound/fixedamp) / halfpi
    let s32 = Int32(scaledsound)

    // filename explanation: numbers between underscores are freq range (in mHz) that"s sonified in audible range.
    let ssps = Double(bandstupto20Hz) * fsps!
    wavfile.write(soundname + "_400_20000.wav",ssps,s32)

    axes(xlim=[0,realduration], ylim=[ymin,ymax], xlabel="time (hours)",ylabel="ground velocity (mm/s)", title=station+" "+channel+" "+date)
    // plot y in mm (or mm/s) rather than m:
    plot(hours,1000.*sound)
    axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
    //show()
    savefig(soundname + ".png")

    //system("open " + soundname + ".png")
    //system("afplay " + soundname + "_400_20000.wav&")
}
