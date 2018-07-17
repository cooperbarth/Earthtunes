import kivy
kivy.require('1.10.1')
#import earthtunes27
import numpy
import urllib2
import matplotlib.pyplot as plt
import random
import re

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
from datetime import date, timedelta
from kivy.graphics import Color, Rectangle
from functools import partial
from kivy.uix.popup import Popup

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
	else:
		print('Defaulting to Ryerson Station...')
		soundname = 'ryerson'
		station = "L44A"
		net = "TA"
		location = "--"
		channel = "BHZ"
		
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
	fsps = numpy.float(head.split()[4])
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

	#setting amplitude and frequency based on user input
	if AF == '0.1 Hz':
		bandsHZ = 64000
	elif AF == '0.5 Hz':
		bandsHZ = 16000
	elif AF == '5 Hz':
		bandsHZ = 1600
	elif AF == '10 Hz':
		bandsHZ = 800
	elif AF == '50 Hz':
		bandsHZ = 160
	else:
		bandsHZ = 400
		
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
	wavfile.write(soundname + "_400_20000.wav",ssps,s32)
	
	#plotting the graph
	axes(xlim=[0,realduration], ylim=[1000*mns,1000*mxs], xlabel="Time since "+time+ " (hours)",ylabel="Ground Velocity (mm/s)", title=locate+', '+date)
	plot(hours,1000.*sound)
	axishours = [time]
	axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
	savefig(soundname + ".png")
	
	return soundname

#isdigit function that works with scientific notation
def isNumber(number):
	try:
		float(number)
	except:
		return False
	return True		
	
	
	
#define labels with different colored backgrounds
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
			
#textinputs that can only accept certain arguments			
class FloatInput(TextInput):
	pat = re.compile('[^0-9]')
	def insert_text(self, substring, from_undo=False):
		pat = self.pat
		if self.text.count('.') > 0:
			s = re.sub(pat, '', substring)
		else:
			s = '.'.join([re.sub(pat, '', s) for s in substring.split('.', 1)])
		return super(FloatInput, self).insert_text(s, from_undo=from_undo)

class TimeInput(TextInput):
	pat = re.compile('[^0-9]')
	def insert_text(self, substring, from_undo=False):
		pat = self.pat
		if self.text.count(':') > 0:
			s = re.sub(pat, '', substring)
		else:
			s = ':'.join([re.sub(pat, '', s) for s in substring.split(':', 1)])
		return super(TimeInput, self).insert_text(s, from_undo=from_undo)
		
		
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
		
		
#screen transition functions
def toDisplay(instance):
	global geofacts
	sm.transition.direction = 'left'
	
	#Checking for Error in User Input
	locationText = sm.get_screen('Input Screen').location.text
	dateText = sm.get_screen('Input Screen').date.text
	startText = sm.get_screen('Input Screen').startTime.text + ":00"
	durationText = sm.get_screen('Input Screen').duration.text
	
	if locationText == 'Select Location' or startText == '' or durationText == '':
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Empty Field(s).'
		return
	if len(startText) is not 8 or (startText[:2] + startText[3:5]).isdigit() is False or startText[2] <> ':' or int(startText[:2]) > 23 or int(startText[3:5]) > 59:
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Invalid Start Time.'
		return
	if float(durationtext) > 1440:
		sm.current = 'Input Error Screen'
		sm.get_screen('Input Error Screen').errorlabel.text = 'Input Error: Please Choose a Shorter Duration.'
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
	
	
	
#screen classes
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
		
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		self.select = Button(text='Select', font_size=20, size_hint=(1,0.109), bold=True)
		self.select.bind(on_release=Selected)
		self.layout.add_widget(self.select)
		self.add_widget(self.layout)
	
choose = ChooseScreen(name='Choose Screen')
sm.add_widget(choose)

class AdvancedScreen(Screen):
	def __init__(self, **kwargs):
		super(AdvancedScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		self.title = BlueLabel(text="SonifyMe", size_hint=(1,0.109), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.layout.add_widget(self.title)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		
		self.aFactor = Spinner(
				text='Acceleration Factor:',
				values=('0.1 Hz', '0.5 Hz', '5 Hz', '10 Hz', '20 Hz', '50 Hz'),
				size_hint = (1,0.08),
				sync_height=True	
				)	
		self.layout.add_widget(self.aFactor)
		self.layout.add_widget(Label(size_hint=(1,0.49)))
		
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		self.grid = GridLayout(cols=2, size_hint=(1, 0.149))
		self.fixedlabel = Label(text='Fixed Amplitude:')
		self.fixedlabel.font_size = self.fixedlabel.height/5
		self.grid.add_widget(self.fixedlabel)
		self.fixedAmp = FloatInput(multiline=False)
		self.fixedAmp.font_size = self.fixedAmp.height/3
		self.fixedAmp.padding = [6, self.fixedAmp.height/2 - self.fixedAmp.font_size/2]
		self.grid.add_widget(self.fixedAmp)
		self.layout.add_widget(self.grid)
		
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		self.returnbutton = Button(text='Return', size_hint=(1,0.149))
		self.returnbutton.font_size=self.returnbutton.height/5
		self.returnbutton.bind(on_release=toInputSimple)
		self.layout.add_widget(self.returnbutton)
		
		self.add_widget(self.layout)
		
class Calendar(BoxLayout):

	def __init__(self, *args, **kwargs):
		super(Calendar, self).__init__(**kwargs)
		self.date = date.today()
		self.orientation = "vertical"
		self.month_names = ('January',
							'February', 
							'March', 
							'April', 
							'May', 
							'June', 
							'July', 
							'August', 
							'September', 
							'October',
							'November',
							'December')
		if kwargs.has_key("month_names"):
			self.month_names = kwargs['month_names']
		self.header = BoxLayout(orientation = 'horizontal', 
								size_hint = (1, 0.2))
		self.body = GridLayout(cols = 7)
		self.add_widget(self.header)
		self.add_widget(self.body)

		self.populate_body()
		self.populate_header()

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
			if date_cursor > date.today():
				date_label.background_color = [0, 0, 0, 1]
			else:
				date_label.bind(on_release=partial(self.set_date, day=date_cursor.day))
			self.body.add_widget(date_label)
			date_cursor += timedelta(days = 1)
			
	def set_date(self, *args, **kwargs):
		self.date = date(self.date.year, self.date.month, kwargs['day'])
		sm.get_screen('Input Screen').date.text = self.date.strftime('%Y-%m-%d')
		sm.get_screen('Input Screen').popup.dismiss()
		self.populate_body()
		self.populate_header()

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

class InputScreen(Screen):

	def __init__(self, **kwargs):
		global choose
		global on_focus
	
		super(InputScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.title = BlueLabel(text="SonifyMe", size_hint=(1,0.1085), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.layout.add_widget(self.title)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))
		
		self.grid0 = GridLayout(cols=2, rows=1, size_hint=(1, 0.1885))
		self.LocationLabel = Label(text='Location:', valign='middle')
		self.LocationLabel.font_size = self.LocationLabel.height/5
		self.grid0.add_widget(self.LocationLabel)
		self.location = Button(text=choose.location.text, valign='middle')
		self.location.font_size=self.location.height/5
		self.location.bind(on_release=toChoose)
		self.grid0.add_widget(self.location)
		self.layout.add_widget(self.grid0)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))
		
		self.grid1 = GridLayout(cols=2, rows=1, size_hint=(1, 0.1885))
		self.datelabel = Label(text='Date (YYYY-MM-DD):')
		self.datelabel.font_size = self.datelabel.height/5
		self.datelabel.valign = 'middle'
		self.grid1.add_widget(self.datelabel)
		self.calendar = Calendar(as_popup=True)
		self.popup=Popup(title='Select Date:', content = self.calendar, size_hint = (0.9,0.5))
		self.date = TextInput(multiline=False, text = date.today().strftime('%Y-%m-%d'), text_align = 'center')
		self.date.bind(focus=on_focus)
		self.date.font_size = self.date.height/3
		self.date.padding = [6, self.date.height/2 - self.date.font_size/2]
		self.grid1.add_widget(self.date)
		
		self.layout.add_widget(self.grid1)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))
		
		self.grid2 = GridLayout(cols=2, rows=1, size_hint=(1,0.1885))
		self.grid2.add_widget(Label(text='Start Time (HH:MM):', font_size=self.height/5, valign='middle'))
		self.startTime = TimeInput(multiline=False)
		self.startTime.font_size = self.startTime.height/3
		self.startTime.padding = [6, self.startTime.height/2 - self.startTime.font_size/2]
		self.grid2.add_widget(self.startTime)
		self.layout.add_widget(self.grid2)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))
		
		self.grid3 = GridLayout(cols=2, rows=1, size_hint=(1,0.1885))
		self.grid3.add_widget(Label(text='Duration (minutes):', font_size=self.height/5, valign='middle'))
		self.duration = FloatInput(multiline=False)
		self.duration.font_size = self.duration.height/3
		self.duration.padding = [6, self.duration.height/2 - self.duration.font_size/2]
		self.grid3.add_widget(self.duration)
		self.layout.add_widget(self.grid3)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))
		
		self.advanced = Button(text='Advanced Options', font_size = self.height/7, size_hint=(1, 0.0385), valign='middle', background_color=(0, 0, 1, 1))
		self.advanced.bind(on_release=toAdvanced)
		self.layout.add_widget(self.advanced)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))
		
		self.button = Button(text='Submit', font_size=self.height/7, size_hint=(1,0.089), valign='middle')
		self.button.bind(on_release=toDisplay)
		self.layout.add_widget(self.button)
		
		self.add_widget(self.layout)

def on_focus(instance, value):
	if value:
		sm.get_screen('Input Screen').popup.open()
	else:
		pass

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
		self.button.bind(on_release=toInputSimple)
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