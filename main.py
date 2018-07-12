import kivy
#import earthtunes27
import numpy
import urllib2
kivy.require('1.10.1')

from scipy.io import wavfile
from matplotlib.pyplot import *
from datetime import datetime, timedelta
from os import path, system

from kivy.app import App
from kivy.uix.gridlayout import GridLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.image import Image
from kivy.uix.spinner import Spinner
from kivy.lang import Builder
from kivy.core.audio import SoundLoader
from datetime import datetime

# Create screen manager
sm = ScreenManager()

#Preload sound and image. These will be reloaded later for correct files
sound = SoundLoader.load('ryerson_400_20000.wav')
im = Image(source="ryerson.png")

#playSound: Play the currently loaded sound
def playSound(instance):
	if sound: #Check if it exists
		sound.play()
	else:
		return

def getSoundAndGraph(location, date, time, duration):
	halfpi = 0.5*numpy.pi
	duration = str(float(duration) * 60)
	disploc = location
	time = time + ':00'
	
	if location == 'Ryerson (IL,USA)':
		soundname = 'ryerson'
		station = "L44A"
		net = "TA"
		location = "--"
		channel = "BHZ"
	elif location == 'Yellowstone (WY,USA)':
		soundname = 'yellowstone' 
		station = "H17A"
		net = "TA"
		location = "--"
		channel = "BHZ"
	elif location == 'Antarctica':
		soundname = 'antarctica'
		station = 'BELA'
		net = 'AI'
		location = '04'
		channel = 'BHZ'
	elif location == 'Chile':
		soundname = 'chile'
		station = 'LCO'
		net = 'IU'
		location = '10'
		channel = 'BHZ'
	elif location == 'Anchorage (AK,USA)':
		soundname = 'alaska'
		station = 'ARTY'
		net = 'NP'
		location = '01'
		channel = 'HNZ'
	elif location == "Kyoto, Japan":
		soundname = 'japan'
		station = 'JWT'
		net = 'JP'
		location = '--'
		channel = 'BHZ'
	elif location == 'London, UK':
		soundname = 'london'
		station = 'HMNX'
		net = 'GB'
		location = '--'
		channel = 'BHZ'
	elif location == 'Ar Rayn, Saudi Arabia':
		soundname = 'saudiarabia'
		station = 'RAYN'
		net = 'II'
		location = '10'
		channel = 'BHZ'
	else:
		print('Defaulting to Ryerson Station...')
		soundname = 'ryerson'
		station = "L44A"
		net = "TA"
		location = "--"
		channel = "BHZ"
		
	print "Getting data from",disploc,'on',date
	
	# Example dates:
		# a specific random day (with 2 thunderstorms):
			# date = "2016-07-24"
		# Alaska M6.2 & Alaska M6.2 
			#date = "2017-05-01"
		# M5.8 Montana and M6.5 Philippines 
			#date = "2017-07-06"
		# Oklahoma M4.2
			#date = "2017-07-14"

	# 6 different time series acceleration factors ("stretch" factors in the frequency domain).
	# only one of them is used in line 99 and 110.
	bandstupto50Hz = 160
	bandstupto20Hz = 400
	bandstupto10Hz = 800
	bandstupto5Hz = 1600
	bandstuptohalfHz = 16000
	bandstuptotenthHz = 64000

	# request data from IRIS' timeseries web service
	type = net + "&sta=" + station + "&loc=" + location + "&cha=" + channel
	when = "&starttime=" + date + "T" + time + "&duration=" + duration
	url = "http://service.iris.edu/irisws/timeseries/1/query?net=" + type + when + "&demean=true&scale=auto&output=ascii1"

	print "requesting data from IRIS...please be patient..."
	#sm.get_screen('Loading Screen').message.text = "requesting data from IRIS...please be patient..."
	ws = urllib2.urlopen(url)
	print "loading data ..."
	#sm.get_screen('Loading Screen').message.text = 'loading data...'
	df = ws.read()
	print "processing data..."
	#sm.get_screen('Loading Screen').message.text = 'processing data...'
	dflines = df.split('\n')
	   
	head = dflines[0]
	# sampling rate in data:
	fsps = numpy.float(head.split()[4])
	# total number of samples in data:
	tot = numpy.float(head.split()[2])
	sound = []
	maxAmp = 0
	for l in dflines[1:-1]:
		if isNumber(l):
			l = float(l)
			sound.append(l)
			maxAmp = max(maxAmp, abs(l))
		else:
			tot = tot + numpy.float(l.split()[2])
	sound = numpy.asarray(sound)

	# use a fixed amplitude scale for seismograms with physical (m/s) y-axis units (use "scale=AUTO" in web request)
	# calculate signal level (in physical units (m/s)) to which you want sound to scale quasi-linearly (one-third of the maximum signal)
	fixedamp = maxAmp / 3.
	
	# duration of data (in hours):
	realduration = (tot/fsps)/3600.
	print "original duration = %7.2f hours" % realduration
	hours = numpy.linspace(0,realduration,tot)

	soundduration = tot/(fsps*bandstupto20Hz)
	print "max 20Hz wav file duration = %8.1f seconds" % (soundduration)

	mxs = 1.01*numpy.max(sound)
	mns = 1.01*numpy.min(sound)

	# An arctan() function is used to keep sound from overshooting and destroying speakers (the IRIS audio service calls this "compression" -- I guess!)
	scaledsound = (2**31)*numpy.arctan(sound/fixedamp)/halfpi
	s32 = numpy.int32(scaledsound)

	# filename explanation: numbers between underscores are freq range (in mHz) that's sonified in audible range.
	ssps = bandstupto20Hz * fsps
	wavfile.write(soundname + "_400_20000.wav",ssps,s32)

	axes(xlim=[0,realduration], ylim=[1000*mns,1000*mxs], xlabel="time (hours)",ylabel="ground velocity (mm/s)", title=station+' '+channel+' '+date)
	# plot y in mm (or mm/s) rather than m:
	plot(hours,1000.*sound)
	axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
	savefig(soundname + ".png")
	
	return soundname

def isNumber(number):
	try:
		float(number)
	except:
		return False
	return True		
		
#toDisplay: transitions to Loading Screen; calls earthtunes and reloads sound/image to match
def toDisplay(instance):
	sm.transition.direction = 'left'
	sm.current = 'Loading Screen'

#toInput: transitions back to input screen; stops sound, resets picture
def toInput(instance):
	if sound.state is 'play':
		sound.stop()
	sm.get_screen('Display Screen').layout.remove_widget(im)
	sm.transition.direction = 'right'
	sm.current = 'Input Screen'
	
def toInputSimple(instance):
	sm.transition.direction = 'right'
	sm.current = 'Input Screen'
	
def toChoose(instance):
	sm.transition.direction = 'left'
	sm.current = 'Choose Screen'
	
def Selected(instance):
	sm.transition.direction = 'right'
	sm.current = 'Input Screen'
	sm.get_screen('Input Screen').location.text = choose.location.text
	
class ChooseScreen(Screen):
	def __init__(self, **kwargs):
		super(ChooseScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.location = Spinner(
							# default value shown
							text='Select:',
							# available values
							values=('Ryerson (IL,USA)', 'Yellowstone (WY,USA)', 'Anchorage (AK,USA)',
									'Kyoto, Japan', 'Chile', 'London, UK', 'Ar Rayn, Saudi Arabia', 
									'Addis Ababa, Ethiopia', 'Antarctica')
							)
		self.layout.add_widget(self.location)
		
		self.select = Button(text='Select', font_size=14)
		self.select.bind(on_release=Selected)
		self.layout.add_widget(self.select)
		self.add_widget(self.layout)
	
choose = ChooseScreen(name='Choose Screen')
	
class InputScreen(Screen):
    
	def __init__(self, **kwargs):
		global choose
	
		super(InputScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.layout.add_widget(Label(text='Location'))				#Location Entry
		
		txt = choose.location.text
		self.location = Button(text=txt, font_size=14)
		self.location.bind(on_release=toChoose)
		self.layout.add_widget(self.location)
		
		self.layout.add_widget(Label(text='Date (YYYY-MM-DD)')) 	#Date Entry
		self.date = TextInput(multiline=False)
		self.layout.add_widget(self.date)
		
		self.grid = GridLayout(cols=4)								#Time  Entry
		self.grid.add_widget(Label(text='Start Time (HH:MM)'))	
		self.startTime = TextInput(multiline=False)
		self.grid.add_widget(self.startTime)
		self.grid.add_widget(Label(text='Duration (minutes)'))
		self.duration = TextInput(multiline=False)
		self.grid.add_widget(self.duration)
		
		self.layout.add_widget(self.grid)
		
		self.button = Button(text='Submit',font_size=14)			#Submit Button
		self.button.bind(on_release=toDisplay)
		self.layout.add_widget(self.button)
		
		self.add_widget(self.layout)
		
class LoadingScreen(Screen):
	
	def __init__(self, **kwargs):
		super(LoadingScreen, self).__init__(**kwargs)
		self.message = Label(text='Loading...')
		self.add_widget(self.message)
		
	def on_enter(self):
		global sound
		
		#Checking for Error in User Input
		locationText = sm.get_screen('Input Screen').location.text
		dateText = sm.get_screen('Input Screen').date.text
		startText = sm.get_screen('Input Screen').startTime.text + ":00"
		durationText = sm.get_screen('Input Screen').duration.text
		
		if locationText == 'Select:' or dateText == '' or startText == '' or durationText == '':
			print 'Please fill out all fields'
			return
		if len(dateText) is not 10 or (dateText[0:3] + dateText[5:6] + dateText[8:9]).isdigit() is False or dateText[4] + dateText[7] <> '--':
			print 'Invalid Date'
			return
		if len(startText) is not 8 or (startText[0:1] + startText[3:4]).isdigit() is False or startText[2] <> ':':
			print 'Invalid Start Time'
			return
		if durationText.isdigit() is False:
			print 'Invalid Duration'
			return
			
		thenDate = datetime.strptime(dateText + startText, '%Y-%m-%d%H:%M:%S')
		if thenDate >= datetime.now():
			print 'Date is out of range'
			return

		#The Actual Transition Code
		sm.transition.direction = 'left'
		sm.current = 'Display Screen'
		try:
			name = getSoundAndGraph(
								sm.get_screen('Input Screen').location.text, 
								sm.get_screen('Input Screen').date.text,
								sm.get_screen('Input Screen').startTime.text,
								sm.get_screen('Input Screen').duration.text)
		except urllib2.HTTPError:
			sm.current = 'Error Screen'
		else:	
			#sm.get_screen('Loading Screen').message.text='Loading...'
			im.source = name + '.png'
			im.reload()
			sound = SoundLoader.load(name + '_400_20000.wav')
			sm.get_screen('Display Screen').layout.add_widget(im, index=2) 

class Error404(Screen):
	
	def __init__(self, **kwargs):
		super(Error404, self).__init__(**kwargs)
		self.layout = GridLayout(cols=1)
		self.message = Label(text="Sorry, your data couldn\'t be found!\nIt may be possible that the station was offline or had not yet been established at your requested time.\nRecheck your inputs")
		self.message.halign = 'center'
		self.button = Button(text='Return')
		self.button.bind(on_press=toInputSimple)
		self.layout.add_widget(self.message)
		self.layout.add_widget(self.button)
		self.add_widget(self.layout)
		
class DisplayScreen(Screen):

	def __init__(self, **kwargs):
		super(DisplayScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.play = Button(text='Play')					#Play Button
		self.play.bind(on_release=playSound)
		self.layout.add_widget(self.play)
		self.button = Button(text='Return')				#Return button
		self.button.bind(on_release=toInput)
		self.layout.add_widget(self.button)
		
		self.add_widget(self.layout)

# Create screens and add to manager
input = InputScreen(name='Input Screen')
loading = LoadingScreen(name='Loading Screen')
display = DisplayScreen(name='Display Screen')
error = Error404(name='Error Screen')

sm.add_widget(input)
sm.add_widget(loading)
sm.add_widget(display)
sm.add_widget(error)
sm.add_widget(choose)

sm.current = 'Input Screen'

class SonifyMe(App):

	def build(self):
		return sm

if __name__ == '__main__':
	SonifyMe().run()