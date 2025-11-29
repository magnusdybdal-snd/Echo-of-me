extends AudioStreamPlayer
# (autoloaded in Project Settings → AutoLoad) as "AudioPlayer"

# Background music audio files.
const music_tracks = {
	"outside": preload("res://assets/audio/freesound_org/music/832628__jadis0x__calm-ambient-piano-loop.wav"),
	"cave": preload("res://assets/audio/freesound_org/music/829069__boatlanman__deep-ambient-bass-loop-160bpm.wav"),
	"menu": preload("res://assets/audio/freesound_org/music/833915__bassimat__atonal-ambient-texture-004-try-it-now.wav")
}

# Plays music by track name (e.g., "outside", "cave"...)
func play_music(track_name: String, volume = 0.0):
	if track_name not in music_tracks:
		push_warning("Unknown music track: " + track_name)
		return

	var music = music_tracks[track_name]

	# Ensures that music plays continuously if already playing
	if stream == music:
		print("DEBUG: stream = music, dont play another track.")
		return

	stream = music
	volume_db = volume
	play()
	print("DEBUG: started playing " + track_name)
