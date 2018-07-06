import kivy
kivy.require('1.10.0')

from kivy.app import App
from kivy.uix.gridlayout import GridLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.lang import Builder

# Formats the screens
Builder.load_string("""
<InputScreen>:
    BoxLayout:
        Label:
			text: 'Location'
		Label:
			text: 'Date'
        Button:
            text: 'Submit'
			on_press: 
				root.manager.transition.direction = 'left'
				root.manager.current = 'Display Screen'

<DisplayScreen>:
    BoxLayout:
        Button:
            text: 'Return'
            on_press: 
				root.manager.transition.direction = 'right'
				root.manager.current = 'Input Screen'
""")

# Declare both screens
class InputScreen(Screen):
    pass

class DisplayScreen(Screen):
    pass

# Create screen manager
sm = ScreenManager()

# Create screens and add to manager
input = InputScreen(name='Input Screen')
display = DisplayScreen(name='Display Screen')

sm.add_widget(input)
sm.add_widget(display)

sm.current = 'Input Screen'




#def segue(instance):
#	print('hi')

#class InputScreen(GridLayout):
	
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
		
#class DisplayScreen(Label):
#	def __init__(self,**kwargs):
#		super(DisplayScreen, self).__init__(**kwargs)
#		self.text = 'hi'

class SonifyMe(App):

	def build(self):
		return sm
		


if __name__ == '__main__':
	SonifyMe().run()

