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

# Maps ambience track names to their pitch scale (1.0 = normal speed/pitch)
const ambience_pitch_scales = {
	"cave_atmos": 0.25
}

const DEFAULT_MUSIC_VOLUME = -18.0
const DEFAULT_AMBIENCE_VOLUME = -24.0

# SFX collections - arrays of sounds for random selection
const sfx_collections = {
	"jump": [
		preload("res://assets/audio/player-sounds_v01/jump-01.mp3"),
		preload("res://assets/audio/player-sounds_v01/jump-02.mp3"),
		preload("res://assets/audio/player-sounds_v01/jump-03.mp3"),
		preload("res://assets/audio/player-sounds_v01/jump-04.mp3"),
		preload("res://assets/audio/player-sounds_v01/jump-05.mp3")
	],
	"landing": [
		preload("res://assets/audio/player-sounds_v01/landing-01.mp3")
	],
	"die": [
		preload("res://assets/audio/player-sounds_v01/die-03.mp3")
	],
	"dash": [
		preload("res://assets/audio/player-sounds_v01/dash-01.mp3"),
		preload("res://assets/audio/player-sounds_v01/dash-02.mp3")
	]
}

# Maps SFX names to their audio buses
const sfx_buses = {
	"jump": "reverb",
	"landing": "reverb",
	"die": "reverb",
	"dash": "reverb"
}

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
	
	# Set pitch scale from mapping, default to 1.0 (normal speed/pitch)
	ambience_player.pitch_scale = ambience_pitch_scales.get(track_name, 1.0)
	
	ambience_player.play()
	print("DEBUG: started playing ambience: " + track_name + " on bus: " + ambience_player.bus + " at pitch: " + str(ambience_player.pitch_scale))

# Stops ambience playback
func stop_ambience():
	if ambience_player.playing:
		ambience_player.stop()
		print("DEBUG: stopped ambience")

# Plays a random SFX from the collection
# Uses global audio (non-positional) since camera follows player
func play_sfx(sfx_name: String, volume_db: float = 0.0):
	if sfx_name not in sfx_collections:
		push_warning("Unknown SFX: " + sfx_name)
		return

	var sounds = sfx_collections[sfx_name]
	if sounds.is_empty():
		push_warning("No sounds in SFX collection: " + sfx_name)
		return

	# Pick random sound from collection
	var random_sound = sounds[randi() % sounds.size()]

	# Create one-shot audio player that deletes itself after playing
	var player = AudioStreamPlayer.new()
	player.stream = random_sound
	player.volume_db = volume_db
	player.bus = sfx_buses.get(sfx_name, "Master")
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
