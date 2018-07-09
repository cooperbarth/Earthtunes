import kivy
kivy.require('1.10.0')

from kivy.app import App
from kivy.uix.gridlayout import GridLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.lang import Builder
from kivy.core.audio import SoundLoader



# Formats the screens
#Builder.load_string("""
#<InputScreen>:
#    BoxLayout:
#		orientation: 'vertical'
#        Label:
#			text: 'Location'
#		Label:
#			text: 'Date'
#       Button:
#            text: 'Submit'
#			on_press: 
#				root.manager.transition.direction = 'left'
#				root.manager.current = 'Display Screen'
#
#<DisplayScreen>:
#    BoxLayout:
#		orientation: 'vertical'
#        Button:
#            text: 'Return'
#            on_press: 
#				root.manager.transition.direction = 'right'
#				root.manager.current = 'Input Screen'
#""")

# Create screen manager
sm = ScreenManager()

def playSound(instance):
	sound = SoundLoader.load('ryerson_400_20000.wav')
	if sound:
		sound.play()

def toDisplay(instance):
	sm.transition.direction = 'left'
	sm.current = 'Display Screen'
	
def toInput(instance):
	sm.transition.direction = 'right'
	sm.current = 'Input Screen'

# Declare both screens
class InputScreen(Screen):
    
	def __init__(self, **kwargs):
		super(InputScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.layout.add_widget(Label(text='Location'))
		self.layout.location = TextInput(multiline=False)
		self.layout.add_widget(self.layout.location)
		self.layout.add_widget(Label(text='Date'))
		self.layout.date = TextInput(multiline=False)
		self.layout.add_widget(self.layout.date)
		self.layout.button = Button(text='Submit',font_size=14)
		self.layout.button.bind(on_press=toDisplay)
		self.layout.add_widget(self.layout.button)
		
		self.add_widget(self.layout)

class DisplayScreen(Screen):

	def __init__(self, **kwargs):
		super(DisplayScreen, self).__init__(**kwargs)
		self.layout = BoxLayout(orientation='vertical')
		
		self.play = Button(text='Play')
		self.play.bind(on_press=playSound)
		self.layout.add_widget(self.play)
		self.button = Button(text='Return')
		self.button.bind(on_press=toInput)
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


#def segue(instance):
#	print('hi')
#
#class InputScreen(GridLayout):
#	
#	def __init__(self, **kwargs):
#		super(InputScreen, self).__init__(**kwargs)
#		self.cols = 2
#		self.add_widget(Label(text='Location'))
#		self.location = TextInput(multiline=False)
#		self.add_widget(self.location)
#		self.add_widget(Label(text='Date'))
#		self.date = TextInput(multiline=False)
#		self.add_widget(self.date)
#		self.button = Button(text='Submit',font_size=14)
#		self.button.bind(on_press=segue)
#		self.add_widget(self.button)
#		
#class DisplayScreen(Label):
#	def __init__(self,**kwargs):
#		super(DisplayScreen, self).__init__(**kwargs)
#		self.text = 'hi'