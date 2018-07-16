import kivy
kivy.require('1.10.1')
#import earthtunes27
import numpy
import urllib2
import matplotlib.pyplot as plt
import random

plt.style.use(['dark_background'])

from scipy.io import wavfile
from matplotlib.pyplot import *
from datetime import datetime, timedelta
from os import path, system

from kivy.app import App
from kivy.clock import Clock
from kivy.uix.gridlayout import GridLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.image import Image
from kivy.uix.spinner import Spinner
from kivy.uix.slider import Slider
from kivy.lang import Builder
from kivy.core.audio import SoundLoader
from datetime import datetime
from kivy.graphics import Color, Rectangle

# Create screen manager
sm = ScreenManager()

#Preload sound and image. These will be reloaded later for correct files
sound = SoundLoader.load('ryerson_400_20000.wav')
im = Image(source="ryerson.png", size_hint=(1,0.8))

#playSound: Play the currently loaded sound
def playSound(instance):
	if sound.state is 'play': #Pause
		sound.stop()
		Clock.unschedule(slideUpdate)
		sm.get_screen('Display Screen').play.text='Play'
	elif sound: #Check if it exists
		slider = sm.get_screen('Display Screen').seek
		sound.play()
		if slider.value <> 0: #Play again after pause
			sound.seek((slider.value/slider.max)*sound.length)
		Clock.schedule_interval(slideUpdate, 0.5)
		sm.get_screen('Display Screen').play.text='Pause'
	else:
		return
		
#jumpBack: Jump back button, goes back 10 seconds
def jumpBack(instance): 
	if sound.state is 'play':
		if (sound.get_pos()-10)<0: #Restarts if before 10 seconds pass
			sound.seek(0)
		else:
			sound.seek(sound.get_pos()-10)
	else:
		return

#jumpForward: Jump forward button, goes forward 10 seconds
def jumpForward(instance):	
	if sound.state is 'play':
		if (sound.get_pos()+10)>sound.length: #Stops if less than 10 seconds until end
			sound.stop()
			Clock.unschedule(slideUpdate)
			sm.get_screen('Display Screen').seek.value=0
			sm.get_screen('Display Screen').play.text='Play'
		else:
			sound.seek(sound.get_pos()+10)
	else:
		return
		
#slideUpdate: Update function for slider to match audio		
def slideUpdate(dt): 
	slider = sm.get_screen('Display Screen').seek
	slider.value = (sound.get_pos()/sound.length)*100

#slidePause: Moving slider pauses sound
def slidePause(instance, touch): 
	if instance.collide_point(*touch.pos):
		if sound.state is 'play':
			sound.stop()

#slideSeek: Start playing audio at new location			
def slideSeek(instance,touch):	
	if instance.collide_point(*touch.pos):
		slider = sm.get_screen('Display Screen').seek
		slider.value_pos = touch.pos
		if sound.state is 'play':
			sound.play()
			sound.seek((slider.value/slider.max)*sound.length)

#getSoundAndGraph: Script that pulls data and processes into image and audio
def getSoundAndGraph(locate, date, time, duration, AF, FA):
	halfpi = 0.5*numpy.pi
	duration = str(float(duration) * 60)
	disploc = locate
	time = time + ':00'
	
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
	if AF == '':
		bandsHZ = 400
	else:
		bandsHZ = float(AF)
	
	#bandstupto50Hz = 160
	#bandstupto20Hz = 400
	#bandstupto10Hz = 800
	#bandstupto5Hz = 1600
	#bandstuptohalfHz = 16000
	#bandstuptotenthHz = 64000

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
	if FA == '':
		fixedamp = maxAmp / 3.
	else:
		fixedamp = float(FA)
	
	# duration of data (in hours):
	realduration = (tot/fsps)/3600.
	print "original duration = %7.2f hours" % realduration
	hours = numpy.linspace(0,realduration,tot)

	soundduration = tot/(fsps*bandsHZ)
	print "max 20Hz wav file duration = %8.1f seconds" % (soundduration)

	mxs = 1.01*numpy.max(sound)
	mns = 1.01*numpy.min(sound)

	# An arctan() function is used to compress sound
	scaledsound = (2**31)*numpy.arctan(sound/fixedamp)/halfpi
	s32 = numpy.int32(scaledsound)

	# filename explanation: numbers between underscores are freq range (in mHz) that's sonified in audible range.
	ssps = bandsHZ * fsps
	wavfile.write(soundname + "_400_20000.wav",ssps,s32)

	axes(xlim=[0,realduration], ylim=[1000*mns,1000*mxs], xlabel="Time since "+time+ " (hours)",ylabel="Ground Velocity (mm/s)", title=locate+', '+date)
	# plot y in mm (or mm/s) rather than m:
	plot(hours,1000.*sound)
	
	axishours = [time]
	axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
	savefig(soundname + ".png")
	
	return soundname

def isNumber(number):
	try:
		float(number)
	except:
		return False
	return True		
	
class BlueLabel(Label):
	def on_size(self, *args):
		self.canvas.before.clear()
		with self.canvas.before:
			Color(0, 0, 1, 0.25)
			Rectangle(pos=self.pos, size=self.size)
			
class WhiteLabel(Label):
	def on_size(self, *args):
		self.canvas.before.clear()
		with self.canvas.before:
			Color(1, 1, 1, 1)
			Rectangle(pos=self.pos, size=self.size)
		
geofacts = ['0','1','2','3','4','5','6','7','8','9']
		
#toDisplay: transitions to Loading Screen; calls earthtunes and reloads sound/image to match
def toDisplay(instance):
	global geofacts

	sm.transition.direction = 'left'
	
	#Checking for Error in User Input
	locationText = sm.get_screen('Input Screen').location.text
	dateText = sm.get_screen('Input Screen').date.text
	startText = sm.get_screen('Input Screen').startTime.text + ":00"
	durationText = sm.get_screen('Input Screen').duration.text
	
	if locationText == 'Select Location' or dateText == '' or startText == '' or durationText == '':
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Empty Field(s).'
		return
	if len(dateText) is not 10 or '.' in dateText or (dateText[:3] + dateText[5:7] + dateText[8:10]).isdigit() is False or dateText[4] + dateText[7] <> '--':
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Invalid Date Format.'
		return
		
	if int(dateText[5:7]) > 12 or int(dateText[5:7]) == 0:
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Invalid Date.'
		return
	if dateText[5:7] in ['04', '06', '09', '11']:
		numdays = 30
	elif dateText[5:7] == '02':
		if float(dateText[:4]) % 4. == 0.:
			numdays = 29
		else:
			numdays = 28
	else:
		numdays = 31
	if int(dateText[8:10]) > numdays:
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Invalid Date.'
		return
	
	if len(startText) is not 8 or '.' in startText or (startText[:2] + startText[3:5]).isdigit() is False or startText[2] <> ':' or int(startText[:2]) > 23 or int(startText[3:5]) > 59:
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Invalid Start Time.'
		return
	if '-' in durationText or durationText.isdigit() is False:
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Invalid Duration Format.'
		return
	if int(durationText) == 0:
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Duration Cannot Be Zero.'
		return
	thenDate = datetime.strptime(dateText + startText, '%Y-%m-%d%H:%M:%S')
	if thenDate >= datetime.now():
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Date Out of Range.'
		return
	
	sm.get_screen('Loading Screen').message.text= "Loading data from " + sm.get_screen('Input Screen').location.text + '\n\n\n\n\n' + geofacts[random.randint(0,9)]
	sm.current = 'Loading Screen'

#toInput: transitions back to input screen; stops sound, resets picture
def toInput(instance):
	if sound.state is 'play':
		sound.stop()
	sm.get_screen('Display Screen').layout.remove_widget(im)
	sm.get_screen('Display Screen').play.text = 'Play'
	sm.get_screen('Display Screen').seek.value = 0
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
	
def toInputError(instance):
	sm.transition.direction = 'left'
	sm.current = 'Input Error Screen'
	
def toAdvanced(instance):
	sm.transition.direction = 'left'
	sm.current = 'Advanced Screen'
	
class ChooseScreen(Screen):
	def __init__(self, **kwargs):
		super(ChooseScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.title = BlueLabel(text="SonifyMe", size_hint=(1,0.109), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.layout.add_widget(self.title)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.location = Spinner(
							text='Select Location',
							values=('Ryerson (IL,USA)', 'Yellowstone (WY,USA)', 'Anchorage (AK,USA)',
									'Kyoto, Japan', 'Cachiyuyo, Chile', 'London, UK', 'Ar Rayn, Saudi Arabia', 
									'Addis Ababa, Ethiopia', 'Antarctica'),
							size_hint = (1,0.078),
							sync_height=True
							)
		self.location.bold=True
		self.location.font_size = 20
		self.layout.add_widget(self.location)
		self.layout.add_widget(Label(size_hint = (1, 0.702)))
		self.select = Button(text='Select', font_size=20, size_hint=(1,0.11), bold=True)
		self.select.bind(on_release=Selected)
		self.layout.add_widget(self.select)
		self.add_widget(self.layout)
	
choose = ChooseScreen(name='Choose Screen')
sm.add_widget(choose)

class AdvancedScreen(Screen):
	def __init__(self, **kwargs):
		super(AdvancedScreen, self).__init__(**kwargs)
		self.box = BoxLayout(orientation='vertical')
		self.layout = GridLayout(cols=2, size_hint=(1,0.8))
		
		self.layout.add_widget(Label())
		self.layout.add_widget(Label())
		self.layout.add_widget(Label(text='Acceleration Factor\n(160-64000)', halign='center'))
		self.aFactor = TextInput(multiline=False)
		self.layout.add_widget(self.aFactor)
		self.layout.add_widget(Label())
		self.layout.add_widget(Label())
		self.layout.add_widget(Label(text='Fixed Amplitude'))
		self.fixedAmp = TextInput(multiline=False)
		self.layout.add_widget(self.fixedAmp)
		self.layout.add_widget(Label())
		self.layout.add_widget(Label())
		
		self.returnbutton = Button(text='Return', size_hint=(1,0.2))
		self.returnbutton.bind(on_release=toInputSimple)
		
		self.box.add_widget(self.layout)
		self.box.add_widget(self.returnbutton)
		
		self.add_widget(self.box)

class InputScreen(Screen):
    
	def __init__(self, **kwargs):
		global choose
	
		super(InputScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.title = BlueLabel(text="SonifyMe", size_hint=(1,0.109), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.layout.add_widget(self.title)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.grid0 = GridLayout(cols=2, rows=1, size_hint=(1, 0.189))
		self.LocationLabel = Label(text='Location:', valign='middle')
		self.LocationLabel.font_size = self.LocationLabel.height/5
		self.grid0.add_widget(self.LocationLabel)
		self.location = Button(text=choose.location.text, font_size=self.height/7, valign='middle')
		self.location.bind(on_release=toChoose)
		self.grid0.add_widget(self.location)
		self.layout.add_widget(self.grid0)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.grid1 = GridLayout(cols=2, rows=1, size_hint=(1, 0.189))
		self.grid1.add_widget(Label(text='Date (YYYY-MM-DD):', font_size=self.height/5, valign='middle'))
		self.date = TextInput(multiline=False, font_size = self.height/7)
		self.grid1.add_widget(self.date)
		self.layout.add_widget(self.grid1)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.grid2 = GridLayout(cols=2, rows=1, size_hint=(1,0.189))
		self.grid2.add_widget(Label(text='Start Time (HH:MM):', font_size=self.height/5, valign='middle'))
		self.startTime = TextInput(multiline=False, font_size = self.height/7)
		self.grid2.add_widget(self.startTime)
		self.layout.add_widget(self.grid2)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.grid3 = GridLayout(cols=2, rows=1, size_hint=(1,0.189))
		self.grid3.add_widget(Label(text='Duration (minutes):', font_size=self.height/5, valign='middle'))
		self.duration = TextInput(multiline=False, font_size = self.height/7)
		self.grid3.add_widget(self.duration)
		self.layout.add_widget(self.grid3)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.advanced = Button(text='Advanced Options', font_size = self.height/7, size_hint=(1, 0.039), valign='middle', background_color=(0, 0, 1, 1))
		self.advanced.bind(on_release=toAdvanced)
		self.layout.add_widget(self.advanced)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.button = Button(text='Submit', font_size=self.height/7, size_hint=(1,0.089), valign='middle')
		self.button.bind(on_release=toDisplay)
		self.layout.add_widget(self.button)
		
		self.add_widget(self.layout)

class InputError(Screen):
	def __init__(self, **kwargs):
		super(InputError, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		self.errorlabel = Label(text='Input Error')
		self.layout.add_widget(self.errorlabel)
		self.returnbutton = Button(text='Return', font_size=14)
		self.returnbutton.bind(on_release=toInputSimple)
		self.layout.add_widget(self.returnbutton)
		self.add_widget(self.layout)		

input = InputScreen(name='Input Screen')
sm.add_widget(input)
		
class LoadingScreen(Screen):
	global geofacts

	def __init__(self, **kwargs):
		super(LoadingScreen, self).__init__(**kwargs)
		self.message = Label(text="Loading data from " + sm.get_screen('Input Screen').location.text + '\n\n\n\n\n' + geofacts[random.randint(0,9)], halign='center')
		self.add_widget(self.message)
		
	def on_enter(self):
		try:
			name = getSoundAndGraph(
								sm.get_screen('Input Screen').location.text, 
								sm.get_screen('Input Screen').date.text,
								sm.get_screen('Input Screen').startTime.text,
								sm.get_screen('Input Screen').duration.text,
								sm.get_screen('Advanced Screen').aFactor.text,
								sm.get_screen('Advanced Screen').fixedAmp.text)
		except urllib2.HTTPError:
			sm.current = 'Error Screen'
		else:	
			global sound
			im.source = name + '.png'
			#im.keep_ratio=False
			im.reload()
			im.size_hint=(1,0.75)
			sound = SoundLoader.load(name + '_400_20000.wav')
			sm.get_screen('Display Screen').layout.add_widget(im, index=3) 
			sm.transition.direction = 'left'
			sm.current = 'Display Screen'

class Error404(Screen):
	
	def __init__(self, **kwargs):
		super(Error404, self).__init__(**kwargs)
		self.layout = GridLayout(cols=1)
		self.message = Label(text="Sorry, your data couldn\'t be found!\nIt may be possible that the station was offline or had not yet been established at your requested time.\nRecheck your inputs.")
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
		
		self.bottom = GridLayout(cols=3,size_hint=(1,0.1))
		
		#Slider --> Allows moving through sound file
		self.seek = Slider(value_track=True, value_track_color=[0, 0, 1, 1], size_hint=(1,0.1))
		self.seek.sensitivity='handle'
		self.seek.bind(on_touch_down=slidePause)
		self.seek.bind(on_touch_up=slideSeek)
		self.layout.add_widget(self.seek)
		
		self.backwards = Button(text='Jump Back')		#Jump Back button
		self.backwards.bind(on_release=jumpBack)
		self.bottom.add_widget(self.backwards)
		self.play = Button(text='Play')					#Play Button
		self.play.bind(on_release=playSound)
		self.bottom.add_widget(self.play)
		self.forwards = Button(text='Jump Forward')		#Jump forward button
		self.forwards.bind(on_release=jumpForward)
		self.bottom.add_widget(self.forwards)

		self.button = Button(text='Return',size_hint=(1,0.05))				#Return button
		self.button.bind(on_release=toInput)
		
		self.layout.add_widget(self.bottom)
		self.layout.add_widget(self.button)
		self.add_widget(self.layout)

# Create screens and add to manager
loading = LoadingScreen(name='Loading Screen')
display = DisplayScreen(name='Display Screen')
error = Error404(name='Error Screen')
inputError = InputError(name='Input Error Screen')
advanced = AdvancedScreen(name='Advanced Screen')

sm.add_widget(loading)
sm.add_widget(display)
sm.add_widget(error)
sm.add_widget(inputError)
sm.add_widget(advanced)

sm.current = 'Input Screen'

class SonifyMe(App):

	def build(self):
		return sm

if __name__ == '__main__':
	SonifyMe().run()