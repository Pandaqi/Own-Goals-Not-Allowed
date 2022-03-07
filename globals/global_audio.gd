extends Node

const MAX_DIST_2D : float = 2000.0
const MAX_DIST_3D : float = 100.0

var is_3D : bool = false

var bg_audio_core = [
	preload("res://audio/core_0.mp3"),
	preload("res://audio/core_1.mp3"),
	preload("res://audio/core_2.mp3"),
	preload("res://audio/core_3.mp3")
]
var bg_audio_embel = [
	preload("res://audio/embel_0.mp3"),
	preload("res://audio/embel_1.mp3"),
	preload("res://audio/embel_2.mp3"),
	preload("res://audio/embel_3.mp3")
]

var bg_custom_volume : float = -6
var bg_audio_player
var bg_audio_player_2

# NOTE: "players" refers to "audio_players" here, not in-game players ...
var active_players = []

var audio_preload = {
	"ball_hit": [
		preload("res://audio/thud1.ogg"),
		preload("res://audio/thud2.mp3"),
		preload("res://audio/thud3.mp3"),
		preload("res://audio/thud4.mp3"),
		preload("res://audio/thud5.mp3"),
		preload("res://audio/thud6.mp3"),
		preload("res://audio/thud7.mp3"),
		preload("res://audio/thud8.mp3"),
		preload("res://audio/thud9.mp3"),
		preload("res://audio/thud10.mp3"),
		preload("res://audio/thud11.mp3"),
		preload("res://audio/thud12.mp3"),
		preload("res://audio/thud13.mp3"),
		preload("res://audio/thud14.mp3"),
		preload("res://audio/thud15.mp3"),
		preload("res://audio/bounce1.ogg"),
		preload("res://audio/bounce3.ogg"),
	],
	"goal": preload("res://audio/goal.ogg"),
	"own_goal": preload("res://audio/own_goal.ogg"),
	"field_change": preload("res://audio/field_change.ogg"),
	"powerup_grab": [
		preload("res://audio/powerup_grab_1.ogg"),
		preload("res://audio/powerup_grab_2.ogg"),
		preload("res://audio/powerup_grab_3.ogg")
	],
	"gameover": preload("res://audio/gameover.ogg"),
	"ui_button": preload("res://audio/ui_button.ogg"),
	"teleport": preload("res://audio/teleport.ogg")
}

func _ready():
	create_background_stream()

func create_background_stream():
	bg_audio_player = AudioStreamPlayer.new()
	bg_audio_player.bus = "BG"
	bg_audio_player.process_mode = PROCESS_MODE_ALWAYS
	bg_audio_player.volume_db = bg_custom_volume
	add_child(bg_audio_player)

	bg_audio_player.stream = bg_audio_core[randi() % bg_audio_core.size()]
	bg_audio_player.play()
	bg_audio_player.finished.connect(bg_core_finished)
	
	bg_audio_player_2 = AudioStreamPlayer.new()
	bg_audio_player.bus = "BG"
	bg_audio_player.process_mode = PROCESS_MODE_ALWAYS
	bg_audio_player_2.volume_db = bg_custom_volume
	add_child(bg_audio_player_2)

	bg_audio_player_2.stream = bg_audio_embel[randi() % bg_audio_embel.size()]
	bg_audio_player_2.play()
	bg_audio_player_2.finished.connect(bg_embel_finished)

func bg_core_finished():
	bg_audio_player.stop()
	bg_audio_player.stream = bg_audio_core[randi() % bg_audio_core.size()]
	bg_audio_player.play()

func bg_embel_finished():
	bg_audio_player_2.stop()
	bg_audio_player_2.stream = bg_audio_embel[randi() % bg_audio_embel.size()]
	bg_audio_player_2.play()

func pick_audio(key):
	var wanted_audio = audio_preload[key]
	if wanted_audio is Array: wanted_audio = wanted_audio[randi() % wanted_audio.size()]
	return wanted_audio

func create_audio_player(volume_alteration, bus : String = "FX", spatial : bool = false, destroy_when_done : bool = true):
	var audio_player
	
	if spatial:
		if is_3D:
			audio_player = AudioStreamPlayer3D.new()
			audio_player.unit_db = volume_alteration
		else:
			audio_player = AudioStreamPlayer2D.new()
			audio_player.volume_db = volume_alteration
	else:
		audio_player = AudioStreamPlayer.new()
		audio_player.volume_db = volume_alteration
	
	audio_player.bus = bus
	
	active_players.append(audio_player)
	
	if destroy_when_done:
		audio_player.finished.connect(self.audio_player_done.bind(audio_player))

	return audio_player

func audio_player_done(which_one):
	active_players.erase(which_one)
	which_one.queue_free()

func play_static_sound(key, volume_alteration = 0, bus : String = "GUI"):
	if not audio_preload.has(key): return
	
	var audio_player = create_audio_player(volume_alteration, bus)

	add_child(audio_player)
	
	audio_player.stream = pick_audio(key)
	audio_player.pitch_scale = 1.0 + 0.02*(randf()-0.5)
	audio_player.play()
	
	return audio_player

func play_dynamic_sound(creator, key, volume_alteration = 0, bus : String = "FX", destroy_when_done : bool = true):
	if not audio_preload.has(key): return
	var audio_player = create_audio_player(volume_alteration, bus, true, destroy_when_done)
	
	var pos = null
	var max_dist = -1
	if audio_player is AudioStreamPlayer2D:
		max_dist = MAX_DIST_2D
		pos = creator.global_position
		audio_player.set_position(pos)
	else:
		max_dist = MAX_DIST_3D
		audio_player.unit_size = max_dist
		pos = creator.transform.origin
		audio_player.set_translation(pos)

	audio_player.max_distance = max_dist
	audio_player.pitch_scale = 1.0 + 0.02*(randf()-0.5)
	
	add_child(audio_player)
	
	audio_player.stream = pick_audio(key)
	audio_player.play()
	
	return audio_player
