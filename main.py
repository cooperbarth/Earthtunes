import kivy
kivy.require('1.10.1')
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
from kivy.core.audio import SoundLoader
from datetime import date, timedelta
from kivy.graphics import Color, Rectangle
from functools import partial
from kivy.uix.popup import Popup

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

#InputError: popup when input errors detected
class InputError(GridLayout):
	def __init__(self, **kwargs):
		super(InputError, self).__init__(**kwargs)
		self.errorlabel = Label(text='Input Error', size_hint=(1, 0.7)) #Label
		self.errorlabel.font_size = self.errorlabel.height/4
		self.cols = 1
		self.add_widget(self.errorlabel)
		self.returnbutton = Button(text='Return', size_hint=(1, 0.3))	#Button
		self.returnbutton.font_size = self.returnbutton.height/5
		self.add_widget(self.returnbutton)

#ChooseScreen: popup screen for choosing location
class ChooseScreen(GridLayout):
	def __init__(self, **kwargs):
		super(ChooseScreen, self).__init__(**kwargs)
		self.cols=1 #One column grid layout
		#SonifyMe header
		self.title = BlueLabel(text="SonifyMe", size_hint=(1,0.109), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.add_widget(self.title)
		self.add_widget(WhiteLabel(size_hint=(1,0.001)))
		#Spinner with all available locations
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
		self.add_widget(self.location)
		self.add_widget(Label(size_hint = (1, 0.702)))
		
		self.add_widget(WhiteLabel(size_hint=(1,0.001)))
		self.select = Button(text='Select', font_size=20, size_hint=(1,0.109), bold=True)
		self.select.bind(on_release=self.closeChoose)
		self.add_widget(self.select)
	
	def closeChoose(self, instance):
		sm.get_screen('Input Screen').location.text = self.location.text
		choosePopup.dismiss()

#AdvancedScreen: Advanced options (like acceleration factor and amplitude)
class AdvancedScreen(BoxLayout):
	def __init__(self, **kwargs):
		super(AdvancedScreen, self).__init__(**kwargs)
		#vertical box layout
		self.layout = BoxLayout(orientation='vertical')
		#SonifyMe header
		self.title = BlueLabel(text="SonifyMe", size_hint=(1,0.109), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.layout.add_widget(self.title)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		#Spinner with acceleration factor choices
		self.aFactor = Spinner(
				text='Acceleration Factor:',
				values=('0.1 Hz', '0.5 Hz', '5 Hz', '10 Hz', '20 Hz', '50 Hz'),
				size_hint = (1,0.08),
				sync_height=True
				)
		self.layout.add_widget(self.aFactor)
		self.layout.add_widget(Label(size_hint=(1,0.49)))
		
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		#Fixed amplitude input as another grid layout
		self.grid = GridLayout(cols=2, size_hint=(1, 0.149))
		self.fixedlabel = Label(text='Fixed Amplitude:') 			#Label
		self.fixedlabel.font_size = self.fixedlabel.height/5
		self.grid.add_widget(self.fixedlabel)
		self.fixedAmp = FloatInput(multiline=False)					#FloatInput (textinput)
		self.fixedAmp.font_size = self.fixedAmp.height/3
		self.grid.add_widget(self.fixedAmp)
		self.layout.add_widget(self.grid)
		
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.001)))
		self.returnbutton = Button(text='Return', size_hint=(1,0.149))	#Return button
		self.returnbutton.font_size=self.returnbutton.height/5
		self.returnbutton.bind(on_release=self.closeAdvanced)
		self.layout.add_widget(self.returnbutton)
		
		self.add_widget(self.layout)
		
	def closeAdvanced(self, instance):
		advancedScreen.dismiss()

#Calendar: Cooper's "God Tier" Calendar for use to pick date
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
		self.hrUp = Button(text='^', size_hint=(0.4,0.2), halign='center', valign='middle')
		self.hrUp.bind(on_release=self.hourUp)
		self.add_widget(self.hrUp)
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.minUp = Button(text='^', size_hint=(0.4,0.2), halign='center', valign='middle')
		self.minUp.bind(on_release=self.minuteUp)
		self.add_widget(self.minUp)
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.AMPMup = Button(text='^', size_hint=(0.1,0.2), halign='center', valign='middle')
		self.AMPMup.bind(on_release=self.apSwitch)
		self.add_widget(self.AMPMup)
		#Value display, ":", and spacing
		self.hour = Label(text='12', size_hint=(0.4, 0.6), halign='center', valign='middle')
		self.hour.font_size = self.hour.height/3
		self.add_widget(self.hour)
		self.colon = Label(text=':', size_hint=(0.05, 0.6), halign='center', valign='middle')
		self.colon.font_size = self.colon.height/3
		self.add_widget(self.colon)
		self.minute = Label(text='00', size_hint=(0.4,0.6), halign='center', valign='middle')
		self.minute.font_size = self.minute.height/3
		self.add_widget(self.minute)
		self.add_widget(Label(size_hint=(0.05,0.6)))
		self.AMPM = Label(text='AM', size_hint=(0.1,0.6), halign='center', valign='middle')
		self.AMPM.font_size = self.minute.height/5
		self.add_widget(self.AMPM)
		#Down buttons and spacing
		self.hrDown = Button(text='v', size_hint=(0.4,0.2), halign='center', valign='middle')
		self.hrDown.bind(on_release=self.hourDown)
		self.add_widget(self.hrDown)
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.minDown = Button(text='v', size_hint=(0.4,0.2), halign='center', valign='middle')
		self.minDown.bind(on_release=self.minuteDown)
		self.add_widget(self.minDown)
		self.add_widget(Label(size_hint=(0.05,0.2)))
		self.AMPMdown = Button(text='v', size_hint=(0.1,0.2), halign='center', valign='middle')
		self.AMPMdown.bind(on_release=self.apSwitch)
		self.add_widget(self.AMPMdown)
	
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
		
		sm.get_screen('Input Screen').startButton.text = hour + ':' + self.minute.text

#InputScreen: Screen for all inputs to be entered
class InputScreen(Screen):
	# def focusDate(self, instance):
		# self.date.focus = True
	# def setDateText(self, instance, value):
		# self.durButton.text = self.duration.text

	def __init__(self, **kwargs):

		super(InputScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')

		#SonifyMe header
		self.title = BlueLabel(text="SonifyMe", size_hint=(1,0.1085), valign='middle', bold=True, halign = 'center')
		self.title.font_size = self.title.height/3
		self.title.bind(size=self.title.setter('text_size'))
		self.layout.add_widget(self.title)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))

		#Location Input
		self.grid0 = GridLayout(cols=2, rows=1, size_hint=(1, 0.1885))
		self.LocationLabel = Label(text='Location:', valign='middle')
		self.LocationLabel.font_size = self.LocationLabel.height/5
		self.grid0.add_widget(self.LocationLabel)
		self.location = Button(text="Ryerson (IL,USA)", valign='middle')
		self.location.font_size=self.location.height/5
		self.location.bind(on_release=self.openChoose)
		self.grid0.add_widget(self.location)
		self.layout.add_widget(self.grid0)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))

		#Date Input
		self.grid1 = GridLayout(cols=2, rows=1, size_hint=(1, 0.1885))
		self.datelabel = Label(text='Date (YYYY-MM-DD):', valign = 'middle')
		self.datelabel.font_size = self.datelabel.height/5
		self.grid1.add_widget(self.datelabel)
		self.calendar = Calendar(as_popup=True)
		self.popup=Popup(title='Select Date:', content = self.calendar, size_hint = (0.9,0.5))
		self.date = Button(text = date.today().strftime('%Y-%m-%d'), background_normal = '', background_color = (0,0,1,0.25), color = (1,1,1,1))
		self.date.font_size = self.date.height/3
		self.date.bind(on_release=lambda x:self.popup.open())
		self.grid1.add_widget(self.date)
		self.layout.add_widget(self.grid1)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))

		#Time Input
		self.grid2 = GridLayout(cols=2, rows=1, size_hint=(1,0.1885))
		self.grid2.add_widget(Label(text='Start Time (HH:MM):', font_size=self.height/5, valign='middle'))
		self.clock = TimePicker(as_popup=True)
		self.timePop=Popup(title='Select Time:', content = self.clock, size_hint=(0.9,0.5))
		self.timePop.bind(on_dismiss=self.clock.set_time)
		self.startButton = Button(text = '00:00', background_normal = '', background_color = (0,0,1,0.25), color = (1,1,1,1))
		self.startButton.font_size = self.startButton.height/3
		self.startButton.bind(on_release=lambda x:self.timePop.open())
		self.grid2.add_widget(self.startButton)
		self.layout.add_widget(self.grid2)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))

		#Duration Input
		self.grid3 = GridLayout(cols=2, rows=1, size_hint=(1,0.1885))
		self.grid3.add_widget(Label(text='Duration (hours):', font_size=self.height/5, valign='middle'))
		self.duration = FloatInput(multiline=False, text='2')
		self.duration.bind(text=self.setDurText)
		self.firstClickHappened = False
		self.durButton = Button(text='2', background_normal = '', background_color = (1,1,1,1), color = (0,0,0,1))
		self.durButton.font_size = self.durButton.height/3
		self.durButton.bind(on_release=self.focusDuration)
		self.grid3.add_widget(self.durButton)
		self.layout.add_widget(self.grid3)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))

		#Advanced Options Button
		self.advanced = Button(text='Advanced Options', font_size = self.height/7, size_hint=(1, 0.0385), valign='middle', background_color=(0, 0, 1, 1))
		self.advanced.bind(on_release=self.openAdvanced)
		self.layout.add_widget(self.advanced)
		self.layout.add_widget(WhiteLabel(size_hint=(1,0.0015)))

		#Submit Button
		self.button = Button(text='Submit', font_size=self.height/7, size_hint=(1,0.089), valign='middle')
		self.button.bind(on_release=self.toDisplay)
		self.layout.add_widget(self.button)

		errscreen.returnbutton.bind(on_release=lambda x:errpopup.dismiss())

		self.add_widget(self.layout)

	def focusDuration(self, instance):
		self.duration.focus = True
		if self.firstClickHappened is False:
			self.firstClickHappened is True
			self.duration.text = ''

	def setDurText(self, instance, value):
		self.durButton.text = self.duration.text

	#toDisplay: screen transition functions
	def toDisplay(self, instance):
		sm.transition.direction = 'left'

		#Checking for Error in User Input
		locationText = self.location.text
		dateText = self.date.text
		startText = self.startButton.text + ":00"
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
		loadScreen.message.text= "Loading data from " + locationText + '\n\n\n\n\n' + geofacts[random.randint(0,9)]
		loadPopup.open()

	#dumb functions to open popups
	def openAdvanced(self,instance):
		advancedScreen.open()

	def openChoose(self,instance):
		choosePopup.open()

#Error404: Screen displayed when failing to download data from IRIS
class Error404(GridLayout):
	def __init__(self, **kwargs):
		super(Error404, self).__init__(**kwargs)
		self.cols=1
		self.message = Label(text="Sorry, your data couldn\'t be found!\nIt may be possible that the station was offline or had not yet been established at your requested time.\nRecheck your inputs.")
		self.message.halign = 'center'
		self.button = Button(text='Return')
		self.button.bind(on_release=self.toInputSimple)
		self.add_widget(self.message)
		self.add_widget(self.button)
	#toInputSimple: error404 to input screen transition	
	def toInputSimple(self,instance):
		sm.transition.direction = 'right'
		sm.current = 'Input Screen'
		errpopup2.dismiss()	#close popup

#LoadingScreen: popup loading screen
class LoadingScreen(GridLayout):
	def __init__(self, **kwargs):
		self.cols = 1
		super(LoadingScreen, self).__init__(**kwargs)
		self.message = Label(halign = 'center')
		self.add_widget(self.message)
		
	#loadData: Gets data and processes and prepares Display Screen
	def loadData(self, instance):
		sound = sm.get_screen('Display Screen').sound
		try:
			soundname = self.getSoundAndGraph(
								sm.get_screen('Input Screen').location.text, 
								sm.get_screen('Input Screen').date.text,
								sm.get_screen('Input Screen').startButton.text,
								sm.get_screen('Input Screen').duration.text,
								advScreen.aFactor.text,
								advScreen.fixedAmp.text)
		except urllib2.HTTPError:
			loadPopup.dismiss()
			errpopup2.open()
		else:
			sm.get_screen('Display Screen').im.source = soundname + '.png'
			sm.get_screen('Display Screen').im.reload()
			sound = SoundLoader.load(soundname + '.wav')
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
		wavfile.write(soundname + ".wav",ssps,s32)

		#plotting the graph
		axes(xlim=[0,realduration], ylim=[1000*mns,1000*mxs], xlabel="Time since "+time+ " (hours)",ylabel="Ground Velocity (mm/s)", title=locate+', '+date)
		plot(hours,1000.*sound)
		axishours = [time]
		axis([hours[0],hours[-1],-3000.*fixedamp,3000.*fixedamp])
		savefig(soundname + ".png")

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

		self.im = Image(source="Blank", size_hint=(1,0.8))
		self.layout.add_widget(self.im, index=3)

		self.bottom = GridLayout(cols=3,size_hint=(1,0.1))

		#Slider allows moving through sound file
		self.seek = Slider(value_track=True, value_track_color=[0, 0, 1, 1], size_hint=(1,0.1))
		self.seek.sensitivity='handle'
		self.seek.bind(on_touch_down=self.slidePause)
		self.seek.bind(on_touch_up=self.slideSeek)
		self.layout.add_widget(self.seek)

		self.backwards = Button(text='Jump Back')		#Jump Back button
		self.backwards.bind(on_release=self.jumpBack)
		self.bottom.add_widget(self.backwards)
		self.play = Button(text='Play')					#Play Button
		self.play.bind(on_release=self.playSound)
		self.bottom.add_widget(self.play)
		self.forwards = Button(text='Jump Forward')		#Jump forward button
		self.forwards.bind(on_release=self.jumpForward)
		self.bottom.add_widget(self.forwards)

		self.button = Button(text='Return',size_hint=(1,0.05))				#Return button
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

# Create screen manager
sm = ScreenManager()

#Creating ErrorScreen popup
errscreen = InputError(as_popup = True) #Create InputError Popup
errpopup=Popup(content = errscreen, title="Input Error", size_hint = (0.9,0.5))

#Creating Error404 popup
errscreen2 = Error404(as_popup = True)
errpopup2=Popup(title = 'ERROR 404', content = errscreen2, size_hint = (0.9,0.5))
		
#Creating ChooseScreen popup
chooseScreen = ChooseScreen(as_popup=True)
choosePopup=Popup(title='Select Location', content = chooseScreen, size_hint = (0.9, 0.8))
		
#Creating AdvancedScreen popup
advScreen = AdvancedScreen(as_popup = True)
advancedScreen=Popup(title = 'Advanced Options', content = advScreen, size_hint = (0.7,0.95))	

#Create LoadingScreen popup
loadScreen = LoadingScreen(as_popup=True)
loadPopup = Popup(title='Loading', content = loadScreen, size_hint = (0.9, 0.5))
loadPopup.bind(on_open=loadScreen.loadData)	
		
#Creating Input Screen
input = InputScreen(name='Input Screen')
sm.add_widget(input)
		
#Create Display Screen
display = DisplayScreen(name='Display Screen')
sm.add_widget(display)

sm.current = 'Input Screen'

class SonifyMe(App):

	def build(self):
		return sm

if __name__ == '__main__':
	SonifyMe().run()