import kivy
kivy.require('1.10.0')

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

import earthtunes27

# Create screen manager
sm = ScreenManager()

sound = SoundLoader.load('ryerson_400_20000.wav')
im = Image(source="ryerson.png")


def playSound(instance):
	if sound:
		sound.play()
	else:
		return

def toDisplay(instance):
	if sm.get_screen('Input Screen').location.text == 'Select:':
		return
	if sm.get_screen('Input Screen').date.text == '':
		return
	if sm.get_screen('Input Screen').startTime.text == '':
		return
	if sm.get_screen('Input Screen').duration.text == '':
		return
	
	global sound
	sm.transition.direction = 'left'
	sm.current = 'Display Screen'
	name = earthtunes27.getSoundAndGraph(
						sm.get_screen('Input Screen').location.text, 
						sm.get_screen('Input Screen').date.text,
						sm.get_screen('Input Screen').startTime.text,
						sm.get_screen('Input Screen').duration.text)
	im.source = name + '.png'
	im.reload()
	sound = SoundLoader.load(name + '_400_20000.wav')
	sm.get_screen('Display Screen').layout.add_widget(im, index=2) 
	
def toInput(instance):
	sm.transition.direction = 'right'
	sm.current = 'Input Screen'
	if sound.state is 'play':
		sound.stop()
	sm.get_screen('Display Screen').layout.remove_widget(im)
	
# Declare both screens
class InputScreen(Screen):
    
	def __init__(self, **kwargs):
		super(InputScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.layout.add_widget(Label(text='Location'))
		
		self.location = Spinner(
							# default value shown
							text='Select:',
							# available values
							values=('Select:', 'Ryerson (IL,USA)', 'Yellowstone (WY,USA)', 'More to come')
							# just for positioning in our example
							#size_hint=(None, None),
							#size=(100, 44),
							#pos_hint={'center_x': .5, 'center_y': .5})
							)
		self.layout.add_widget(self.location)
		
		self.layout.add_widget(Label(text='Date (YYYY-MM-DD)'))
		self.date = TextInput(multiline=False)
		self.layout.add_widget(self.date)
		
		self.layout.add_widget(Label(text='Start Time (HH:MM:SS)'))
		self.startTime = TextInput(multiline=False)
		self.layout.add_widget(self.startTime)
		self.layout.add_widget(Label(text='Duration (minutes)'))
		self.duration = TextInput(multiline=False)
		self.layout.add_widget(self.duration)
		
		self.button = Button(text='Submit',font_size=14)
		self.button.bind(on_release=toDisplay)
		self.layout.add_widget(self.button)
		
		self.add_widget(self.layout)

class DisplayScreen(Screen):

	def __init__(self, **kwargs):
		super(DisplayScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.play = Button(text='Play')
		self.play.bind(on_release=playSound)
		self.layout.add_widget(self.play)
		self.button = Button(text='Return')
		self.button.bind(on_release=toInput)
		self.layout.add_widget(self.button)
		
		self.add_widget(self.layout)

# Create screens and add to manager
input = InputScreen(name='Input Screen')
display = DisplayScreen(name='Display Screen')

sm.add_widget(input)
sm.add_widget(display)

sm.current = 'Input Screen'

class SonifyMe(App):

	def build(self):
		return sm

if __name__ == '__main__':
	SonifyMe().run()