#!/usr/bin/python

import numpy
import urllib.request, urllib.error, urllib.parse
from scipy.io import wavfile
from matplotlib.pyplot import *
from datetime import datetime, timedelta
from os import path, system

def getSoundAndGraph(location, date):
	halfpi = 0.5*numpy.pi

	#soundname = 'midewin'
	#station = "M44A"
	#net = "N4"
	#location = "--"
	#channel = "HHZ"

	soundname = 'ryerson'
	station = "L44A"
	net = "TA"
	location = "--"
	channel = "BHZ"

	#soundname = 'yellowstone' 
	#station = "H17A"
	#net = "TA"
	#location = "--"
	#channel = "BHZ"

	# use a fixed amplitude scale for seismograms with physical (m/s) y-axis units (use "scale=AUTO" in web request)
	# An arctan() function is used to keep sound from overshooting and destroying speakers (the IRIS audio service calls this "compression" -- I guess!)
	# enter the signal level (in physical units (m/s)) to which you want sound to scale quasi-linearly (about a third of the expected maximum signal)
	fixedamp = 5.e-5

	# yesterday:
	yesterday = datetime.today() - timedelta(days=1)
	date = yesterday.strftime('%Y-%m-%d')
	print("Getting yesterday's Ryerson data, ",date)

	# a specific random day (with 2 thunderstorms):
	# date = "2016-07-24"

	# Alaska M6.2 & Alaska M6.2 
	#date = "2017-05-01"

	# M5.8 Montana and M6.5 Philippines 
	#date = "2017-07-06"

	# Oklahoma M4.2
	#date = "2017-07-14"

	time = "00:00:00"

	duration = "86400"   #  in seconds = 24 hours
	#duration = "21600"  # 6 hours

	# 6 different time series acceleration factors ("stretch" factors in the frequency domain).
	# only one of them is used in line 101.
	bandstupto50Hz = 160
	bandstupto20Hz = 400
	bandstupto10Hz = 800
	bandstupto5Hz = 1600
	bandstuptohalfHz = 16000
	bandstuptotenthHz = 64000
	#--------------------------------------------------

	# request data from IRIS' timeseries web service, and store in folder "IRISfiles" (make sure it exists) for ipotential repeat use.
	type = net + "&sta=" + station + "&loc=" + location + "&cha=" + channel
	when = "&starttime=" + date + "T" + time + "&duration=" + duration
	url = "http://service.iris.edu/irisws/timeseries/1/query?net=" + type + when + "&demean=true&scale=auto&output=ascii1"
	sfn = "IRISfiles/" + station + "." + net + ".." + channel + "." + date + "." + duration + ".rm.scale-AUTO.txt"
	print('Requesting ',url)
	print('Saved in ',sfn)

	if path.isfile(sfn): 	#Reading from saved file
		print("reading previously requested data from saved file...")
		rsfn = open(sfn,'r')
		df = rsfn.read()
		dflines = df.split('\n')
	else:					#Retrieving data from website
		print("requesting data from IRIS...please be patient...")
		#ws = urllib.request.urlopen(url)		#Old implementation, replaced with urlretrieve
		urllib.request.urlretrieve(url,sfn)
		print("loading data ...")
		#df = ws.read()							#Old implementation, replaced with urlretrieve
		rsfn = open(sfn,'r')
		df = rsfn.read()
		print("processing data...")
		#dflines = df.decode().split('\n')  	#Old implementation, replaced with urlretrieve
		#wsfn = open(sfn,'w')      				#Old implementation, replaced with urlretrieve
		#wsfn.write(df.decode()) 				#Old implementation, replaced with urlretrieve
		dflines = df.split('\n')
	  
	head = dflines[0]
	sound = numpy.array([float(l) for l in dflines[1:-1]])
	# sampling rate in data:
	fsps = numpy.float(head.split()[4])
	# total number of samples in data:
	tot = numpy.float(head.split()[2])
	# duration of data (in hours):
	realduration = (tot/fsps)/3600.
	print("original duration = %7.2f hours" % realduration)
	hours = numpy.linspace(0,realduration,tot)

	soundduration = tot/(fsps*bandstupto20Hz)
	print("max 20Hz wav file duration = %8.1f seconds" % (soundduration))

	mxs = 1.01*numpy.max(sound)
	mns = 1.01*numpy.min(sound)

	# use fixed_amplitude:
	scaledsound = (2**31)*numpy.arctan(sound/fixedamp)/halfpi
	s32 = numpy.int32(scaledsound)

	# filename explanation: numbers between underscores are freq range (in mHz) that's sonified in audible range.
	ssps = numpy.int32(bandstupto20Hz * fsps)
	wavfile.write(soundname + "_400_20000.wav",ssps,s32)

	axes(xlim=[0,realduration], ylim=[-3*fixedamp,fixedamp*3], xlabel="time (hours)",ylabel="ground velocity (mm/s)", title=station+' '+channel+' '+date)
	# plot y in mm (or mm/s) rather than m:
	plot(hours,1000.*sound)
	axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
	#show()
	savefig(soundname + ".png")

	#system("open " + soundname + ".png")
	#system("afplay " + soundname + "_400_20000.wav&")

