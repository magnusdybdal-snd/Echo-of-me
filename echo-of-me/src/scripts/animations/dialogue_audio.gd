extends AudioStreamPlayer


func _dialogue(voice_number: String, volume: float) -> void:
	AudioPlayer.play_dialogue(voice_number, volume)
