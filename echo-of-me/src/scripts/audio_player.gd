extends AudioStreamPlayer
# (autoloaded in Project Settings → AutoLoad) as "AudioPlayer"

# Background music audio files.
const music_tracks = {
	"outside": preload("res://assets/audio/freesound_org/music/832628__jadis0x__calm-ambient-piano-loop.wav"),
	"cave": preload("res://assets/audio/freesound_org/music/829069__boatlanman__deep-ambient-bass-loop-160bpm.wav"),
	"menu": preload("res://assets/audio/freesound_org/music/833915__bassimat__atonal-ambient-texture-004-try-it-now.wav"),
	"test_level": preload("res://assets/audio/freesound_org/music/811735__cvltiv8r__tweaker-pad-pluck-melody-loop-in-d-and-a-110bpm.wav")
}

const ambience_tracks = {
	"birds": preload("res://assets/audio/freesound_org/ambience/799439__sadiquecat__250418_10h28-gergueil-west-ortf.wav"),
	"cave_atmos": preload("res://assets/audio/freesound_org/ambience/613175__tferrino__construction-site-air-hammer-extday-amb-atmo-st-48k24b.wav"),
}

# Maps ambience track names to their audio buses
const ambience_buses = {
	"birds": "nature",
	"cave_atmos": "cave_ambience"
}

const DEFAULT_MUSIC_VOLUME = -18.0
const DEFAULT_AMBIENCE_VOLUME = -0.0

# Separate player for ambience that plays alongside music
var ambience_player: AudioStreamPlayer

func _ready() -> void:
	# Create ambience player as a child node
	ambience_player = AudioStreamPlayer.new()
	add_child(ambience_player)

# Plays music by track name (e.g., "outside", "cave"...)
func play_music(track_name: String, volume = DEFAULT_MUSIC_VOLUME):
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
	print("DEBUG: started playing music: " + track_name)



# Plays ambience by track name (e.g., "birds")
func play_ambience(track_name: String, volume = DEFAULT_AMBIENCE_VOLUME):
	if track_name not in ambience_tracks:
		push_warning("Unknown ambience track: " + track_name)
		return

	var ambience = ambience_tracks[track_name]

	# Ensures that ambience plays continuously if already playing
	if ambience_player.stream == ambience:
		print("DEBUG: ambience already playing, skipping.")
		return

	ambience_player.stream = ambience
	ambience_player.volume_db = volume

	# Set audio bus from mapping, default to "Master" if not specified
	ambience_player.bus = ambience_buses.get(track_name, "Master")

	ambience_player.play()
	print("DEBUG: started playing ambience: " + track_name + " on bus: " + ambience_player.bus)

# Stops ambience playback
func stop_ambience():
	if ambience_player.playing:
		ambience_player.stop()
		print("DEBUG: stopped ambience")
