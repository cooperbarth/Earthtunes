import numpy as np, urllib2
from scipy.io import wavfile
from matplotlib.pyplot import *
matplotlib.pyplot.style.use(['dark_background'])

#getSoundAndGraph: Script that pulls data and processes into image and audio
def getSoundAndGraph(self, locate, date, time, duration, AF, FA):
    halfpi = 0.5*np.pi
    duration = str(float(duration) * 3600)
    disploc = locate
    time = time + ':00'

    #setting location and station based on user input
    if locate == 'Ryerson (IL,USA)':
        soundname = 'ryerson'
        station = "L44A"
        net = "TA"
        location = "--"
        channel = "BHZ"
    elif locate == 'Yellowstone (WY,USA)':
        soundname = 'yellowstone' 
        station = "H17A"
        net = "TA"
        location = "--"
        channel = "BHZ"
    elif locate == 'Antarctica':
        soundname = 'antarctica'
        station = 'BELA'
        net = 'AI'
        location = '04'
        channel = 'BHZ'
    elif locate == 'Cachiyuyo, Chile':
        soundname = 'chile'
        station = 'LCO'
        net = 'IU'
        location = '10'
        channel = 'BHZ'
    elif locate == 'Anchorage (AK,USA)':
        soundname = 'alaska'
        station = 'SSN'
        net = 'AK'
        location = '--'
        channel = 'BHZ'
    elif locate == "Kyoto, Japan":
        soundname = 'japan'
        station = 'JWT'
        net = 'JP'
        location = '--'
        channel = 'BHZ'
    elif locate == 'London, UK':
        soundname = 'london'
        station = 'HMNX'
        net = 'GB'
        location = '--'
        channel = 'BHZ'
    elif locate == 'Ar Rayn, Saudi Arabia':
        soundname = 'saudiarabia'
        station = 'RAYN'
        net = 'II'
        location = '10'
        channel = 'BHZ'
    elif locate == 'Addis Ababa, Ethiopia':
        soundname = 'ethiopia'
        station = 'FURI'
        net = 'IU'
        location = '00'
        channel = 'BHZ'
    else:
        return

    #getting data from online
    print "Getting data from",disploc,'on',date
    type = net + "&sta=" + station + "&loc=" + location + "&cha=" + channel
    when = "&starttime=" + date + "T" + time + "&duration=" + duration
    url = "http://service.iris.edu/irisws/timeseries/1/query?net=" + type + when + "&demean=true&scale=auto&output=ascii1"
    print "requesting data from IRIS...please be patient..."
    ws = urllib2.urlopen(url)
    print "loading data ..."
    df = ws.read()
    print "processing data..."
    dflines = df.split('\n')

    #getting the data from the doc
    head = dflines[0]
    fsps = np.float(head.split()[4])
    tot = np.float(head.split()[2])
    sound = []
    maxAmp = 0
    for l in dflines[1:-1]:
        if self.isNumber(l):
            l = float(l)
            sound.append(l)
            maxAmp = max(maxAmp, abs(l))
        else:
            tot = tot + np.float(l.split()[2])
    sound = np.asarray(sound)

    #setting amplitude and frequency based on user input
    if AF == '0.1 Hz':
        bandsHZ = 64000
    elif AF == '0.5 Hz':
        bandsHZ = 16000
    elif AF == '5 Hz':
        bandsHZ = 1600
    elif AF == '20 Hz':
        bandsHZ = 400
    elif AF == '50 Hz':
        bandsHZ = 160
    else:
        bandsHZ = 800

    if FA == '':
        fixedamp = maxAmp / 3.
    else:
        fixedamp = float(FA)

    #creating the sound file
    realduration = (tot/fsps)/3600.
    print "original duration = %7.2f hours" % realduration
    hours = np.linspace(0,realduration,tot)
    soundduration = tot/(fsps*bandsHZ)
    print "max 20Hz wav file duration = %8.1f seconds" % (soundduration)
    mxs = 1.01*np.max(sound)
    mns = 1.01*np.min(sound)
    scaledsound = (2**31)*np.arctan(sound/fixedamp)/halfpi
    s32 = np.int32(scaledsound)
    ssps = bandsHZ * fsps
    wavfile.write(soundname + ".wav",ssps,s32)

    #plotting the graph
    axes(xlim=[0,realduration], ylim=[1000*mns,1000*mxs], xlabel="Time since "+time+ " (hours)",ylabel="Ground Velocity (mm/s)", title=locate+', '+date)
    plot(hours,1000.*sound)
    axishours = [time]
    axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
    savefig(soundname + ".png",bbox_inches='tight')

    return soundname