import kivy
kivy.require('1.10.1')
import numpy
import urllib2
import random
import re

from scipy.io import wavfile
from matplotlib.pyplot import *
from datetime import date, datetime, timedelta
from functools import partial
from os import path, system

matplotlib.pyplot.style.use(['dark_background'])

from kivy.app import App
from kivy.clock import Clock
from kivy.core.audio import SoundLoader
from kivy.graphics import Color, Rectangle
from kivy.uix.gridlayout import GridLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.image import Image
from kivy.uix.spinner import Spinner
from kivy.uix.slider import Slider
from kivy.uix.popup import Popup
from kivy.uix.checkbox import CheckBox

#InputScreen: Screen for all inputs to be entered
class InputScreen(Screen):
	def __init__(self, **kwargs):
		super(InputScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')

		#SonifyMe header
		self.topGrid=BoxLayout(size_hint=(1,0.1085))
		self.topGrid.add_widget(Label(size_hint=(0.1,1)))
		self.topGrid.add_widget(Label(text="Earthtunes", size_hint=(0.8,1), valign='middle', bold=True, halign = 'center', font_size = self.height/3))
		self.info = Button(text='Explore',background_normal='',background_color=(0,0,0,1),size_hint=(0.1,1))
		self.info.bind(on_release=lambda x:samplePopup.open())
		self.topGrid.add_widget(self.info)
		self.layout.add_widget(self.topGrid)
		self.layout.add_widget(Label(size_hint=(1,0.0015)))

		#Location Input
		self.grid0 = GridLayout(cols=2, rows=1, size_hint=(1, 0.1885))
		self.grid0.add_widget(BlueLabel(text='Location:', valign='middle', font_size = self.height/5, size_hint = (0.35, 0.1885)))
		self.location = Button(text="Ryerson (IL,USA)", valign='middle', background_normal = '', background_color = (1,1,1,1), color = (0,0,0,1), font_size = self.height/4, size_hint = (0.65, 0.1885))
		self.location.bind(on_release=lambda x:choosePopup.open())
		self.grid0.add_widget(self.location)
		self.layout.add_widget(self.grid0)
		self.layout.add_widget(Label(size_hint=(1,0.0015)))

		#Date Input
		self.grid1 = GridLayout(cols=2, rows=1, size_hint=(1, 0.1885))
		self.datelabel = BlueLabel(text='Date:', valign = 'middle', font_size = self.height/5, size_hint = (0.35, 0.1885))
		self.grid1.add_widget(self.datelabel)
		self.calendar = Calendar(as_popup=True)
		self.popup=Popup(title='Select Date:', content = self.calendar, size_hint = (0.9,0.5), background = "black.jpg", separator_color = (1,1,1,1))
		self.date = Button(text = date.today().strftime('%Y-%m-%d'), background_normal = '', background_color = (1,1,1,1), color = (0,0,0,1), font_size = self.height/3,on_release=lambda x:self.popup.open(), size_hint = (0.65, 0.1885))
		self.grid1.add_widget(self.date)
		self.layout.add_widget(self.grid1)
		self.layout.add_widget(Label(size_hint=(1,0.0015)))

		#Time Input
		self.grid2 = GridLayout(cols=2, rows=1, size_hint=(1,0.1885))
		self.grid2.add_widget(BlueLabel(text='Start Time:', font_size=self.height/5, valign='middle', size_hint = (0.35, 0.1885)))
		self.clock = TimePicker(as_popup=True)
		self.timePop=Popup(title='Select Time:', content = self.clock, size_hint=(0.9,0.5), background = "black.jpg", separator_color = (1,1,1,1))
		self.timePop.bind(on_dismiss=self.clock.set_time)
		self.startTime = Button(text = '00:00', background_normal = '', background_color = (1,1,1,1), color = (0,0,0,1), font_size = self.height/3, on_release=lambda x:self.timePop.open(), size_hint = (0.65, 0.1885))
		self.grid2.add_widget(self.startTime)
		self.layout.add_widget(self.grid2)
		self.layout.add_widget(Label(size_hint=(1,0.0015)))

		#Duration Input
		self.grid3 = GridLayout(cols=2, rows=1, size_hint=(1,0.1885))
		self.grid3.add_widget(BlueLabel(text='Duration (hours):', font_size=self.height/5, valign='middle',size_hint = (0.35, 0.1885)))
		self.duration = FloatInput(multiline=False, text='2')
		self.duration.bind(text=self.setDurText)
		self.firstClickHappened = False
		self.durButton = Button(text='2', background_normal = '', background_color = (1,1,1,1), color = (0,0,0,1), font_size = self.height/3, on_release=self.focusDuration, size_hint = (0.65, 0.1885))
		self.cur = False
		self.grid3.add_widget(self.durButton)
		Clock.schedule_interval(self.cursor, 0.5)
		self.layout.add_widget(self.grid3)
		self.layout.add_widget(Label(size_hint=(1,0.0015)))

		#Advanced Options and Submit Buttons
		self.layout.add_widget(Button(text='Advanced Options', font_size = self.height/7, size_hint=(1, 0.0385), background_normal = '', background_color=(0, 0, 0, 1), on_release=lambda x:advancedScreen.open()))
		self.layout.add_widget(Label(size_hint=(1,0.0015)))
		self.layout.add_widget(Button(text='Submit', font_size=self.height/7, size_hint=(1,0.089), valign='middle', on_release=self.toDisplay, background_normal = '', background_color = (1, 1, 1, 1), color = (0,0,0,1)))

		self.add_widget(self.layout)

	def cursor(self, dt):
		if self.duration.focus:
			position = self.duration.cursor[0]
			if not self.cur:
				self.durButton.text = self.duration.text[:position] + "|" + self.duration.text[position:]
				self.cur = True
			else:
				self.durButton.text = self.duration.text[:position] + " " + self.duration.text[position:]
				self.cur = False
		else:
			self.durButton.text = self.duration.text
			self.cur = False

	def focusDuration(self, instance):
		self.duration.focus = True
		if self.firstClickHappened is False:
			self.firstClickHappened is True
			self.duration.text = ''

	def setDurText(self, instance, value):
		if len(self.duration.text) > 2:
			self.duration.text = self.duration.text[0:-1]
		self.durButton.text = self.duration.text

	#toDisplay: screen transition functions
	def toDisplay(self, instance):
		sm.transition.direction = 'left'

		#Checking for Error in User Input
		locationText = self.location.text
		dateText = self.date.text
		startText = self.startTime.text + ":00"
		durationText = self.duration.text

		#list of geology facts for use on the loading screen
		geofacts = ['0',
					'1',
					'2',
					'3',
					'4',
					'5',
					'6',
					'7',
					'8',
					'9']

		if locationText == 'Select Location':
			errscreen.errorlabel.text = 'Input Error: Please Select a Location.'
			errpopup.open()
			return
		if startText == '' or durationText == '':
			errscreen.errorlabel.text = 'Input Error: Empty Field(s).'
			errpopup.open()
			return
		if float(durationText) > 24.:
			errscreen.errorlabel.text = 'Input Error: Please Choose a Shorter Duration.'
			errpopup.open()
			return
		if float(durationText) == 0.:
			errscreen.errorlabel.text = 'Input Error: Duration Cannot Be Zero.'
			errpopup.open()
			return

		#Open loading popup
		loadScreen.message.text= "Loading data from " + locationText + '...\n\n\n\n' + geofacts[random.randint(0,9)]
		loadPopup.open()

#LoadingScreen: popup loading screen
class LoadingScreen(GridLayout):
	def __init__(self, **kwargs):
		self.cols = 1
		super(LoadingScreen, self).__init__(**kwargs)
		self.message = Label(halign = 'center', font_size = self.height/5)
		self.add_widget(self.message)

	#loadData: Gets data and processes and prepares Display Screen
	def loadData(self, instance):
		DS = sm.get_screen('Display Screen')
		try:
			soundname = self.getSoundAndGraph(sm.get_screen('Input Screen').location.text,sm.get_screen('Input Screen').date.text,sm.get_screen('Input Screen').startTime.text,sm.get_screen('Input Screen').duration.text,advScreen.aFactor.text,advScreen.fixedAmp.text)
		except urllib2.HTTPError:
			loadPopup.dismiss()
			errpopup2.open()
		else:
			DS.im.source = soundname + '.png'
			DS.im.reload()
			DS.sound = SoundLoader.load(soundname + '.wav')
			loadPopup.dismiss()
			sm.transition.direction = 'left'
			sm.current = 'Display Screen'

	#getSoundAndGraph: Script that pulls data and processes into image and audio
	def getSoundAndGraph(self, locate, date, time, duration, AF, FA):
		halfpi = 0.5*numpy.pi
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
		url = "http://service.iris.edu/irisws/timeseries/1/query?net=" + type + when + "&demean=true&hp=0.0001&scale=auto&output=ascii1"
		print "requesting data from IRIS...please be patient..."
		ws = urllib2.urlopen(url)
		print "loading data ..."
		df = ws.read()
		print "processing data..."
		dflines = df.split('\n')

		#getting the data from the doc
		head = dflines[0]
		fsps = numpy.float(head.split()[4])
		tot = numpy.float(head.split()[2])
		sound = []
		maxAmp = 0
		for l in dflines[1:-1]:
			if self.isNumber(l):
				l = float(l)
				sound.append(l)
				maxAmp = max(maxAmp, abs(l))
			else:
				tot = tot + numpy.float(l.split()[2])
		sound = numpy.asarray(sound)

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
		hours = numpy.linspace(0,realduration,tot)
		soundduration = tot/(fsps*bandsHZ)
		print "max 20Hz wav file duration = %8.1f seconds" % (soundduration)
		mxs = 1.01*numpy.max(sound)
		mns = 1.01*numpy.min(sound)
		scaledsound = (2**31)*numpy.arctan(sound/fixedamp)/halfpi
		s32 = numpy.int32(scaledsound)
		ssps = bandsHZ * fsps
		wavfile.write(soundname + ".wav",ssps,s32)

		#plotting the graph
		axes(xlim=[0,realduration], ylim=[1000*mns,1000*mxs], xlabel="Time since "+time+ " (hours)",ylabel="Ground Velocity (mm/s)", title=locate+', '+date)
		plot(hours,1000.*sound)
		axishours = [time]
		axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
		savefig(soundname + ".png",bbox_inches='tight')

		return soundname

	#isNumber: isdigit function that works with scientific notation
	def isNumber(self, number):
		try:
			float(number)
		except:
			return False
		return True

#DisplayScreen: Screen that displays graph and controls for playing associated sound
class DisplayScreen(Screen):
	def __init__(self, **kwargs):
		super(DisplayScreen, self).__init__(**kwargs)
		#Preload sound. This will be reloaded later for correct files
		self.sound = SoundLoader.load('ryerson.wav')
		self.layout = BoxLayout(orientation='vertical')

		self.topGrid = GridLayout(cols=3,size_hint=(1,0.8))
		self.topGrid.add_widget(Label(size_hint=(0.1,1)))
		self.im = Image(source="Blank", size_hint=(0.8,1))
		self.im.allow_stretch = True
		self.topGrid.add_widget(self.im)
		self.topGrid.add_widget(Label(size_hint=(0.1,1)))
		self.layout.add_widget(self.topGrid, index=3)

		self.bottom = GridLayout(cols=7,size_hint=(1,0.08))

		#Slider allows moving through sound files
		self.slide = GridLayout(cols=3,size_hint=(1,0.07))
		self.slide.add_widget(Label(size_hint=(0.2,1)))
		self.seek = Slider(value_track=True, value_track_color=[0, 0, 1, 1], size_hint=(0.695,1))
		self.seek.sensitivity='handle'
		self.seek.bind(on_touch_down=self.slidePause)
		self.seek.bind(on_touch_up=self.slideSeek)
		self.slide.add_widget(self.seek)
		self.slide.add_widget(Label(size_hint=(0.105,1)))
		self.layout.add_widget(self.slide)

		self.bottom.add_widget(Label(size_hint=(0.05,1)))
		self.backwards = Button(text='Jump Back',background_normal='', background_color=(1,1,1,1), color=(0,0,0,1))		#Jump Back button
		self.backwards.bind(on_release=self.jumpBack)
		self.bottom.add_widget(self.backwards)
		self.bottom.add_widget(Label(size_hint=(0.05,1)))
		self.play = Button(text='Play',background_normal='', background_color=(1,1,1,1), color=(0,0,0,1))					#Play Button
		self.play.bind(on_release=self.playSound)
		self.bottom.add_widget(self.play)
		self.bottom.add_widget(Label(size_hint=(0.05,1)))
		self.forwards = Button(text='Jump Forward',background_normal='', background_color=(1,1,1,1), color=(0,0,0,1))		#Jump forward button
		self.forwards.bind(on_release=self.jumpForward)
		self.bottom.add_widget(self.forwards)
		self.bottom.add_widget(Label(size_hint=(0.05,1)))

		self.button = Button(text='Return',size_hint=(1,0.05), background_color=(0,0,0,1))				#Return button
		self.button.bind(on_release=self.toInput)
		
		self.layout.add_widget(self.bottom)
		self.layout.add_widget(self.button)
		self.add_widget(self.layout)
		
		#disgusting boolean variable to determine whether sound was paused by touch
		self.wasPlaying = False	

	#playSound: Play the currently loaded sound
	def playSound(self, instance):
		if self.sound.state is 'play': #Pause
			self.sound.stop()
			Clock.unschedule(self.slideUpdate)
			self.play.text='Play'
		elif self.sound: #Check if it exists
			slider = self.seek
			self.sound.play()
			if slider.value <> 0: #Play again after pause
				self.sound.seek((slider.value/slider.max)*self.sound.length)
			Clock.schedule_interval(self.slideUpdate, 0.5)
			self.play.text='Pause'
		else:
			return

	#jumpBack: Jump back button, goes back 10 seconds
	def jumpBack(self, instance): 
		if self.sound.state is 'play':
			if (self.sound.get_pos()-10)<0: #Restarts if before 10 seconds pass
				self.sound.seek(0)
			else:
				self.sound.seek(self.sound.get_pos()-10)
		else:
			return

	#jumpForward: Jump forward button, goes forward 10 seconds
	def jumpForward(self, instance):
		if self.sound.state is 'play':
			if (self.sound.get_pos()+10)>self.sound.length: #Stops if less than 10 seconds until end
				self.sound.stop()
				Clock.unschedule(self.slideUpdate)
				self.seek.value=0
				self.play.text='Play'
			else:
				self.sound.seek(self.sound.get_pos()+10)
		else:
			return

	#slideUpdate: Update function for slider to match audio
	def slideUpdate(self, dt): 
		slider = self.seek
		slider.value = (self.sound.get_pos()/self.sound.length)*100
		if self.sound.state is 'stop' and not self.wasPlaying:
			self.play.text='Play'

	#slidePause: Moving slider pauses sound
	def slidePause(self, instance, touch): 
		if instance.collide_point(*touch.pos):
			if self.sound.state is 'play':
				self.sound.stop()
				self.wasPlaying = True

	#slideSeek: Start playing audio at new location (or move slider if paused)
	def slideSeek(self,instance,touch):
		if instance.collide_point(*touch.pos):
			slider = self.seek
			slider.value_pos = touch.pos
			if self.wasPlaying:
				self.sound.play()
				self.sound.seek((slider.value/slider.max)*self.sound.length)
			self.wasPlaying = False
	
	#toInput: display to input screen transition
	def toInput(self, instance):
		if self.sound.state is 'play':	#stop sound
			self.sound.stop()
		self.play.text = 'Play'			#Reset slider/pause button
		self.seek.value = 0
		sm.transition.direction = 'right'
		sm.current = 'Input Screen'

#ChooseScreen: popup screen for choosing location
class ChooseScreen(GridLayout):
	def __init__(self, **kwargs):
		super(ChooseScreen, self).__init__(**kwargs)
		self.cols=1
		self.off = True
		self.location = Button(text = 'Select Location', size_hint = (1, 0.078), font_size = self.height/7, bold = True, background_normal = '', background_color = (0, 0.13, 0.26, 1), on_release = lambda x:self.showChoices())
		self.add_widget(self.location)
		self.one = Button(text = 'Ryerson (IL,USA)', on_release = lambda x:self.setUpButton(1))
		self.two = Button(text = 'Yellowstone (WY,USA)',on_release = lambda x:self.setUpButton(2))
		self.three = Button(text = 'Anchorage (AK,USA)', on_release = lambda x:self.setUpButton(3))
		self.four = Button(text = 'Kyoto, Japan', on_release = lambda x:self.setUpButton(4))
		self.five = Button(text = 'Cachiyuyo, Chile', on_release = lambda x:self.setUpButton(5))
		self.six = Button(text = 'London, UK',on_release = lambda x:self.setUpButton(6))
		self.seven = Button(text = 'Ar Rayn, Saudi Arabia', on_release = lambda x:self.setUpButton(7))
		self.eight = Button(text = 'Addis Ababa, Ethiopia',on_release = lambda x:self.setUpButton(8))
		self.nine = Button(text = 'Antarctica', on_release = lambda x:self.setUpButton(9))
		self.buttons = [self.one, self.two, self.three, self.four, self.five, self.six, self.seven, self.eight, self.nine]
		for button in self.buttons:
			button.size_hint = (1, 0.078)
			button.background_normal = ''
			button.background_color = (0, 0, 0, 1)
			button.color = (0, 0, 0, 1)
			self.add_widget(button)

		self.add_widget(Label(size_hint=(1,0.001)))
		self.add_widget(Button(text='Select', font_size=self.height/5, size_hint=(1,0.109), on_release=self.closeChoose, background_color=(1,1,1,1),color=(0,0,0,1),background_normal=''))

	def setUpButton(self, value):
		dict = {1:self.one, 2:self.two, 3:self.three, 4:self.four, 5:self.five, 6:self.six, 7:self.seven, 8:self.eight, 9:self.nine}
		self.location.text = dict[value].text
		self.showChoices()

	def showChoices(self):
		if self.off:
			for button in self.buttons:
				button.background_color = (0, 0.13, 0.26, 1)
				button.color = (1, 1, 1, 1)
			self.off = False
		else:
			for button in self.buttons:
				button.background_color = (0, 0, 0, 1)
				button.color = (0, 0, 0, 1)
			self.off = True

	def closeChoose(self, instance):
		sm.get_screen('Input Screen').location.text = self.location.text
		choosePopup.dismiss()

#SampleScreen: popup screen with sample inputs
class SampleScreen(GridLayout):
	def __init__(self, **kwargs):
		super(SampleScreen, self).__init__(**kwargs)
		self.cols=1
		self.layout=GridLayout(cols=2,size_hint=(1,0.9))
		self.layout.add_widget(Label(text='Earthquake from Ryerson\nDate: January 23rd, 2018 Time: 10:00 Duration: 4 hours',size_hint=(0.7,0.148), halign='center'))
		self.one=CheckBox(group='a_group',size_hint=(0.3,0.148))
		self.layout.add_widget(self.one)
		self.layout.add_widget(Label(text='Event 1\nDate: June 2nd, 2017 Time: 00:23 Duration: 4 hours',size_hint=(0.7,0.142), halign='center'))
		self.two=CheckBox(group='a_group',size_hint=(0.3,0.142))
		self.layout.add_widget(self.two)
		self.layout.add_widget(Label(text='Event 2\nDate: November 7th, 2016 Time: 01:30 Duration: 4 hours',size_hint=(0.7,0.142), halign='center'))
		self.three=CheckBox(group='a_group',size_hint=(0.3,0.142))
		self.layout.add_widget(self.three)
		self.layout.add_widget(Label(text='Event 3\nDate: July 6th, 2017 Time: 6:29 Duration: 4 hours',size_hint=(0.7,0.142), halign='center'))
		self.four=CheckBox(group='a_group',size_hint=(0.3,0.142))
		self.layout.add_widget(self.four)
		self.layout.add_widget(Label(text='Event 4\nDate: May 4th, 2018 Time: 22:33 Duration: 4 hours',size_hint=(0.7,0.142), halign='center'))
		self.five=CheckBox(group='a_group',size_hint=(0.3,0.142))
		self.layout.add_widget(self.five)
		self.layout.add_widget(Label(text='Event 5\nDate: July 8th, 2018 Time: 16:30 Duration: 4 hours',size_hint=(0.7,0.142), halign='center'))
		self.six=CheckBox(group='a_group',size_hint=(0.3,0.142))
		self.layout.add_widget(self.six)
		self.layout.add_widget(Label(text='Event 6\nDate: July 24th, 2018 Time: 14:00 Duration: 4 hours',size_hint=(0.7,0.142), halign='center'))
		self.seven=CheckBox(group='a_group',size_hint=(0.3,0.142))
		self.layout.add_widget(self.seven)
		self.add_widget(self.layout)
		
		self.returnbutton = Button(text='Submit', size_hint=(1,0.1), background_normal = '', background_color = (1, 1, 1, 1), color = (0,0,0,1), valign = 'middle')
		self.returnbutton.font_size=self.returnbutton.height/5
		self.returnbutton.bind(on_release=self.closeSample)
		self.add_widget(self.returnbutton)
		
	def closeSample(self,instance):
		input = sm.get_screen('Input Screen')
		if self.one.active:
			input.location.text = 'Ryerson (IL,USA)'
			input.date.text = '2018-01-23'
			input.startTime.text = '08:00'
			input.duration.text = '4'
		elif self.two.active:
			input.location.text = 'Ryerson (IL,USA)'
			input.date.text = '2017-06-02'
			input.startTime.text = '00:00'
			input.duration.text = '4'
		elif self.three.active:
			input.location.text = 'Ryerson (IL,USA)'
			input.date.text = '2016-11-07'
			input.startTime.text = '00:00'
			input.duration.text = '4'
		elif self.four.active:
			input.location.text = 'Ryerson (IL,USA)'
			input.date.text = '2017-07-06'
			input.startTime.text = '05:00'
			input.duration.text = '4'
		elif self.five.active:
			input.location.text = 'Ryerson (IL,USA)'
			input.date.text = '2018-05-04'
			input.startTime.text = '21:00'
			input.duration.text = '4'
		elif self.six.active:
			input.location.text = 'Ryerson (IL,USA)'
			input.date.text = '2018-07-08'
			input.startTime.text = '15:00'
			input.duration.text = '4'
		elif self.seven.active:
			input.location.text = 'Ryerson (IL,USA)'
			input.date.text = '2018-07-24'
			input.startTime.text = '13:00'
			input.duration.text = '4'
		else:
			pass
		samplePopup.dismiss()

#AdvancedScreen: Advanced options (like acceleration factor and amplitude)
class AdvancedScreen(BoxLayout):
	def __init__(self, **kwargs):
		super(AdvancedScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')

		self.topGrid=GridLayout(cols=3, size_hint=(1,0.109))
		self.resetButton = Button(text='Reset', size_hint=(0.1,1), background_normal='',background_color=(0,0,0,1))
		self.resetButton.bind(on_release=self.reset)
		self.topGrid.add_widget(self.resetButton)
		self.title = Label(text="Earthtunes", size_hint=(0.8,1), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.topGrid.add_widget(self.title)
		self.infoButton = Button(text='Info', size_hint=(0.1,1), background_normal='', background_color=(0,0,0,1))
		self.infoButton.bind(on_release=self.infoOpen)
		self.topGrid.add_widget(self.infoButton)
		self.layout.add_widget(self.topGrid)
		self.layout.add_widget(Label(size_hint=(1,0.001)))

		#Spinner with acceleration factor choices
		self.off = True
		self.aFactor = Button(text='Upper Frequency Limit:', size_hint = (1, 0.1), background_normal = '', background_color = (0, 0.13, 0.26, 1), bold = True, on_release = lambda x:self.showChoices())
		self.layout.add_widget(self.aFactor)
		self.one = Button(text = '0.1 Hz', on_release = lambda x:self.setUpButton(1))
		self.two = Button(text = '0.5 Hz',on_release = lambda x:self.setUpButton(2))
		self.three = Button(text = '5 Hz', on_release = lambda x:self.setUpButton(3))
		self.four = Button(text = '10 Hz', on_release = lambda x:self.setUpButton(4))
		self.five = Button(text = '20 Hz', on_release = lambda x:self.setUpButton(5))
		self.six = Button(text = '50 Hz',on_release = lambda x:self.setUpButton(6))
		self.buttons = [self.one, self.two, self.three, self.four, self.five, self.six]
		for button in self.buttons:
			button.size_hint = (1, 0.095)
			button.background_normal = ''
			button.background_color = (0, 0, 0, 1)
			button.color = (0, 0, 0, 1)
			self.layout.add_widget(Label(size_hint = (1, 0.005)))
			self.layout.add_widget(button)
		self.layout.add_widget(Label(size_hint = (1, 0.005)))

		self.grid = GridLayout(cols=2, size_hint=(1, 0.14))
		self.grid.add_widget(BlueLabel(text='Fixed Amplitude:', font_size = self.height/5))
		self.fixedAmpText = FloatInput(multiline=False,text='0.00005')
		self.fixedAmpText.bind(text=self.setTextEqual)
		self.fixedAmp = Button(background_normal = '', color = (0,0,0,1), on_release=self.focusButton)
		self.fixedAmp.font_size = self.fixedAmp.height/3
		self.cur = False
		self.grid.add_widget(self.fixedAmp)
		Clock.schedule_interval(self.cursor, 0.5)
		self.layout.add_widget(self.grid)

		self.returnbutton = Button(text='Return', size_hint=(1,0.15), background_normal = '', background_color = (0, 0, 0, 1), valign = 'middle')
		self.returnbutton.font_size=self.returnbutton.height/5
		self.returnbutton.bind(on_release=lambda x:advancedScreen.dismiss())
		self.layout.add_widget(self.returnbutton)

		self.add_widget(self.layout)

	def setUpButton(self, value):
		dict = {1:self.one, 2:self.two, 3:self.three, 4:self.four, 5:self.five, 6:self.six}
		self.aFactor.text = dict[value].text
		self.showChoices()

	def showChoices(self):
		if self.off:
			for button in self.buttons:
				button.background_color = (0, 0.13, 0.26, 1)
				button.color = (1, 1, 1, 1)
			self.off = False
		else:
			for button in self.buttons:
				button.background_color = (0, 0, 0, 1)
				button.color = (0, 0, 0, 1)
			self.off = True

	def cursor(self, dt):
		if self.fixedAmpText.focus:
			position = self.fixedAmpText.cursor[0]
			if not self.cur:
				self.fixedAmp.text = self.fixedAmpText.text[:position] + "|" + self.fixedAmpText.text[position:]
				self.cur = True
			else:
				self.fixedAmp.text = self.fixedAmpText.text[:position] + " " + self.fixedAmpText.text[position:]
				self.cur = False
		else:
			self.fixedAmp.text = self.fixedAmpText.text
			self.cur = False

	def setTextEqual(self, instance, value):
		if len(self.fixedAmpText.text) > 8:
			self.fixedAmpText.text = self.fixedAmpText.text[0:-1]
		self.fixedAmp.text = self.fixedAmpText.text

	def focusButton(self, instance):
		self.fixedAmpText.focus = True

	def infoOpen(self,instance):
		infoPopup.open()
		advancedScreen.dismiss()

	def reset(self, instance):
		self.aFactor.text='10 Hz'
		self.fixedAmpText.text='0.00005'

#InfoScreen: Information about advanced options

class InfoScreen(GridLayout):
	def __init__(self, **kwargs):
		super(InfoScreen, self).__init__(**kwargs)
		self.cols=1
		self.Label1=Label(text='Upper Frequency Limit (default: 10 Hz):\nThe range of frequencies that are recorded is to wide to fit into the audible range.\nWe use a factor in calculations to listen to specific ranges of frequencies;\n the below choices represent the highest frequency heard with specific multipliers.\nlower frequencies (higher multipliers) are better to hear earthquakes.\nKeep in mind not all stations record at all of these frequencies,\nso data may be sparse for some choices',
								size_hint=(1,0.4),halign='center')
		self.add_widget(self.Label1)
		self.Label2=Label(text='Fixed Amplitude (default: 0.00005):\nThe fixed amplitude is a number used in calculations to help scale the amplitude of the sound.\nSmaller numbers lead to louder sounds, but may distort sounds that are already loud.\nHigher numbers lead to quieter sound, but more detail on louder sounds',
								size_hint=(1,0.4),halign='center')
		self.add_widget(self.Label2)
		self.back = Button(text='Close', background_normal='', background_color=(1,1,1,1), color=(0,0,0,1),size_hint=(1,0.2))
		self.back.bind(on_release=lambda x:infoPopup.dismiss())
		self.add_widget(self.back)

#InputError: popup when input errors detected
class InputError(GridLayout):
	def __init__(self, **kwargs):
		super(InputError, self).__init__(**kwargs)
		self.cols = 1
		self.errorlabel = Label(text='Input Error', size_hint=(1, 0.7), font_size = self.height/4)
		self.add_widget(self.errorlabel)
		self.add_widget(Button(text='Return', size_hint=(1, 0.3), on_release=lambda x:errpopup.dismiss(), font_size = self.height/5, background_color=(1,1,1,1),color=(0,0,0,1),background_normal=''))

#Error404: Screen displayed when failing to download data from IRIS
class Error404(GridLayout):
	def __init__(self, **kwargs):
		super(Error404, self).__init__(**kwargs)
		self.cols=1
		self.add_widget(Label(text="Sorry, your data couldn\'t be found!\nIt may be possible that the station was offline or had not yet been established at your requested time.\nRecheck your inputs.", halign = 'center'))
		self.add_widget(Button(text='Return', on_release=lambda x:errpopup2.dismiss(), background_color=(1,1,1,1),color=(0,0,0,1),background_normal=''))

#Calendar: Cooper's "God Tier" Calendar for use to pick date
class Calendar(BoxLayout):
	def __init__(self, *args, **kwargs):
		super(Calendar, self).__init__(**kwargs)
		self.date = date.today()
		self.orientation = "vertical"
		self.month_names = ('January','February','March','April','May','June','July','August','September','October','November','December')
		if kwargs.has_key("month_names"):
			self.month_names = kwargs['month_names']
		self.header = BoxLayout(orientation = 'horizontal', size_hint = (1, 0.2))
		self.body = GridLayout(cols = 7)
		self.add_widget(self.header)
		self.add_widget(self.body)

		self.populate_body()
		self.populate_header()

	#populate_header: Fills header with correct data (Month, Year), buttons
	def populate_header(self, *args, **kwargs):
		self.header.clear_widgets()
		month_year_text = self.month_names[self.date.month -1] + ' ' + str(self.date.year)
		current_month = Label(text=month_year_text, size_hint = (0.4, 1))
		
		previous_year = Button(text = "<<", size_hint = (0.15, 1), on_release=partial(self.move_previous_year))
		previous_month = Button(text = "<", size_hint = (0.15, 1), on_release=partial(self.move_previous_month))
		next_month = Button(text = ">", size_hint = (0.15, 1), on_release=partial(self.move_next_month))
		next_year = Button(text = ">>", size_hint = (0.15, 1), on_release=partial(self.move_next_year))
		
		self.header.add_widget(previous_year)
		self.header.add_widget(previous_month)
		self.header.add_widget(current_month)
		self.header.add_widget(next_month)
		self.header.add_widget(next_year)

	#populate_body: Fills body with calendar given the month and year. Select date by clicking on a day)
	def populate_body(self, *args, **kwargs):
		self.body.clear_widgets()
		self.days = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
		for dayLabel in self.days:
			self.body.add_widget(Label(text=dayLabel))
		date_cursor = date(self.date.year, self.date.month, 1)
		weekday = date_cursor.isoweekday()
		if weekday is 7:
			weekday = 0
		for filler in range(weekday):
			self.body.add_widget(Label(text=""))
		while date_cursor.month == self.date.month:
			date_label = Button(text = str(date_cursor.day))
			if date_cursor > date.today():	#Make future dates unable to be selected
				date_label.background_color = [0, 0, 0, 1]
			else:
				date_label.bind(on_release=partial(self.set_date, day=date_cursor.day))
			self.body.add_widget(date_label)
			date_cursor += timedelta(days = 1)

	#set_date: Transfers date selected into text_input on Input Screen
	def set_date(self, *args, **kwargs):
		self.date = date(self.date.year, self.date.month, kwargs['day'])
		sm.get_screen('Input Screen').date.text = self.date.strftime('%Y-%m-%d')
		sm.get_screen('Input Screen').popup.dismiss()
		self.populate_body()
		self.populate_header()

	#Functions that correspond to buttons that change month or year
	def move_next_month(self, *args, **kwargs):
		if self.date.month == 12:
			self.date = date(self.date.year + 1, 1, self.date.day)
		else:
			self.date = date(self.date.year, self.date.month + 1, self.date.day)
		self.populate_header()
		self.populate_body()

	def move_previous_month(self, *args, **kwargs):
		if self.date.month == 1:
			self.date = date(self.date.year - 1, 12, self.date.day)
		else:
			self.date = date(self.date.year, self.date.month -1, self.date.day)
		self.populate_header()
		self.populate_body()

	def move_next_year(self, *args, **kwargs):
		if self.date.month == 2 and self.date.day == 29:
			self.date = date(self.date.year + 1, self.date.month, self.date.day - 1)
		else:
			self.date = date(self.date.year + 1, self.date.month, self.date.day)
		self.populate_header()
		self.populate_body()

	def move_previous_year(self, *args, **kwargs):
		if self.date.month == 2 and self.date.day == 29:
			self.date = date(self.date.year - 1, self.date.month, self.date.day - 1)
		else:
			self.date = date(self.date.year - 1, self.date.month, self.date.day)
		self.populate_header()
		self.populate_body()

#TimePicker: clock that allows selection of time
class TimePicker(GridLayout):
	def __init__(self, **kwargs):
		super(TimePicker, self).__init__(**kwargs)
		self.cols = 5

		#Up buttons and spacing 
		self.add_widget(Button(text='^', size_hint=(0.4,0.2), halign='center', valign='middle', on_release=self.hourUp))
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.add_widget(Button(text='^', size_hint=(0.4,0.2), halign='center', valign='middle', on_release=self.minuteUp))
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.add_widget(Button(text='^', size_hint=(0.1,0.2), halign='center', valign='middle', on_release=self.apSwitch))

		#Value display, ":", and spacing
		self.hour = Label(text='12', size_hint=(0.4, 0.6), halign='center', valign='middle', font_size=self.height/3)
		self.add_widget(self.hour)
		self.add_widget(Label(text=':', size_hint=(0.05, 0.6), halign='center', valign='middle', font_size = self.height/3))
		self.minute = Label(text='00', size_hint=(0.4,0.6), halign='center', valign='middle', font_size = self.height/3)
		self.add_widget(self.minute)
		self.add_widget(Label(size_hint=(0.05,0.6)))
		self.AMPM = Label(text='AM', size_hint=(0.1,0.6), halign='center', valign='middle', font_size = self.height/5)
		self.add_widget(self.AMPM)

		#Down buttons and spacing
		self.add_widget(Button(text='v', size_hint=(0.4,0.2), halign='center', valign='middle', on_release=self.hourDown))
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.add_widget(Button(text='v', size_hint=(0.4,0.2), halign='center', valign='middle', on_release=self.minuteDown))
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.add_widget(Button(text='v', size_hint=(0.1,0.2), halign='center', valign='middle', on_release=self.apSwitch))

	#Functions that corresponds to buttons that change hour, minute, or AM/PM
	def hourUp(self, instance):
		currentHour = int(self.hour.text)
		currentHour += 1
		if currentHour == 12:
			self.apSwitch(instance)
		if currentHour == 13:
			currentHour = 1
		if currentHour < 10:
			self.hour.text = '0'+str(currentHour)
		else:
			self.hour.text = str(currentHour)

	def minuteUp(self, instance):
		currentMinute = int(self.minute.text)
		currentMinute += 1
		if currentMinute == 60:
			currentMinute = 0
			
		if currentMinute < 10:
			self.minute.text = '0'+str(currentMinute)
		else:
			self.minute.text = str(currentMinute)

	def hourDown(self, instance):
		currentHour = int(self.hour.text)
		currentHour -= 1
		if currentHour == 11:
			self.apSwitch(instance)
		if currentHour == 0:
			currentHour = 12
		if currentHour < 10:
			self.hour.text = '0'+str(currentHour)
		else:
			self.hour.text = str(currentHour)

	def minuteDown(self, instance):
		currentMinute = int(self.minute.text)
		currentMinute -= 1
		if currentMinute == -1:
			currentMinute = 59
			
		if currentMinute < 10:
			self.minute.text = '0'+str(currentMinute)
		else:
			self.minute.text = str(currentMinute)

	def apSwitch(self, instance):
		if self.AMPM.text == 'AM':
			self.AMPM.text = 'PM'
		else:
			self.AMPM.text = 'AM'
	
	def set_time(self, instance):
		hour = int(self.hour.text)
		if self.AMPM.text == 'PM':
			hour += 12
			if hour == 24:
				hour = 12
		if self.AMPM.text == 'AM':
			if hour == 12:
				hour = 0
		if hour < 10:
			hour = '0'+str(hour)
		else:
			hour = str(hour)
		
		sm.get_screen('Input Screen').startTime.text = hour + ':' + self.minute.text

class BlueLabel(Label):
	def on_size(self, *args):
		self.canvas.before.clear()
		with self.canvas.before:
			Color(0, 0.5, 1, 0.28)
			Rectangle(pos=self.pos, size=self.size)

class WhiteLabel(Label):
	def on_size(self, *args):
		self.canvas.before.clear()
		with self.canvas.before:
			Color(1, 1, 1, 1)
			Rectangle(pos=self.pos, size=self.size)

#FloatInput: TextInput that can only accept certain arguments
class FloatInput(TextInput):
	pat = re.compile('[^0-9]')
	def insert_text(self, substring, from_undo=False):
		pat = self.pat
		if self.text.count('.') > 0:
			s = re.sub(pat, '', substring)
		else:
			s = '.'.join([re.sub(pat, '', s) for s in substring.split('.', 1)])
		return super(FloatInput, self).insert_text(s, from_undo=from_undo)

# Create screen manager
sm = ScreenManager()

#Creating InputError popup
errscreen = InputError(as_popup = True) 
errpopup=Popup(title="Input Error", content = errscreen, size_hint = (0.9,0.5), background = "black.jpg", separator_color = (1,1,1,1))

#Creating Error404 popup
errscreen2 = Error404(as_popup = True)
errpopup2=Popup(title = 'ERROR 404', content = errscreen2, size_hint = (0.9,0.5), background = "black.jpg", separator_color = (1,1,1,1))

#Creating ChooseScreen popup
chooseScreen = ChooseScreen(as_popup=True)
choosePopup=Popup(title='Select Location', content = chooseScreen, size_hint = (0.9, 0.8), background = "black.jpg", separator_color = (1,1,1,1))

#Creating SampleScreen popup
sampleScreen = SampleScreen(as_popup=True)
samplePopup=Popup(title='Sample Inputs', content = sampleScreen, size_hint = (0.8,0.8), background = 'black.jpg', separator_color = (1,1,1,1))

#Creating AdvancedScreen popup
advScreen = AdvancedScreen(as_popup=True)
advancedScreen=Popup(title = 'Advanced Options', content = advScreen, size_hint = (0.9,0.95), background = "black.jpg", separator_color = (1,1,1,1))

#Creating InofScreen popup
infoScreen = InfoScreen(as_popup=True)
infoPopup=Popup(title='Information', content = infoScreen, size_hint = (0.9,0.95), background = 'black.jpg', separator_color = (1,1,1,1))
infoPopup.bind(on_dismiss=lambda x:advancedScreen.open())

#Create LoadingScreen popup
loadScreen = LoadingScreen(as_popup=True)
loadPopup = Popup(title='Loading', content = loadScreen, size_hint = (0.9, 0.5), background = "black.jpg", separator_color = (1,1,1,1), on_open=loadScreen.loadData)

#Creating Screens
input = InputScreen(name='Input Screen')
sm.add_widget(input)
display = DisplayScreen(name='Display Screen')
sm.add_widget(display)

sm.current = 'Input Screen'

class SonifyMe(App):

	def build(self):
		return sm

if __name__ == '__main__':
	SonifyMe().run()