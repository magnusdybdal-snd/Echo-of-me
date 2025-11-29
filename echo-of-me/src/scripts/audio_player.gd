extends AudioStreamPlayer
# (autoloaded in Project Settings → AutoLoad) as "AudioPlayer"

# Background music audop files.
const level_music_outside = preload("res://assets/audio/freesound_org/music/832628__jadis0x__calm-ambient-piano-loop.wav")
const level_music_cave = preload("res://assets/audio/freesound_org/music/829069__boatlanman__deep-ambient-bass-loop-160bpm.wav")

# private function to play music. Default db level is 0
func _play_music(music: AudioStream, volume = 0.0):
	# Ensures that music plays continuously if already playing
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()
	
# Plays different music on outside and inside levels.
func play_music_level(levelIndex: int):
	if levelIndex <= 0:
		_play_music(level_music_outside)
	else:
		_play_music(level_music_cave)
