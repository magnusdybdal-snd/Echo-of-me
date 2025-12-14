extends Control

@onready var _dialogue: RichTextLabel = $VBoxContainer/Dialogue
@onready var _speaker: Label = $VBoxContainer/Speaker

#func _ready():
	#scale = Vector2(1.68, 1.68)
	
func display_line(line : String, speaker : String = ""):
	_speaker.visible = (speaker != "") # speaker only visible when provided
	_speaker.text = speaker
	_dialogue.text = line
	open()
	
func open(): # visibility of dialog box
	visible = true

func close():
	visible = false
