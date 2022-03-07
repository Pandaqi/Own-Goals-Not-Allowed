extends Node2D

@onready var interface_manager = get_parent()

var player_num : int = -1
var team_num : int = -1
var is_active : bool = false
var is_ready : bool = false

@onready var bg = $BG
@onready var remove_area = $RemoveArea
@onready var ready_area = $ReadyArea
@onready var key_hint = $KeyHint

var player_scene : PackedScene = preload("res://objects/player/player.tscn")
var player = null

func set_player_num(p_num : int, t_num : int):
	player_num = p_num
	team_num = t_num

func _physics_process(dt):
	if not is_active: return
	if player == null: return
	
	player.handle_input(GInput.get_move_vec(player_num))

func activate():
	bg.set_frame(1)
	remove_area.set_visible(true)
	ready_area.set_visible(true)
	key_hint.set_visible(true)
	is_active = true
	
	player = player_scene.instantiate()
	player.set_position(Vector2.ZERO)
	add_child(player)
	player.set_data(player_num, team_num)
	
	var split = GInput.get_split_status_for(player_num)
	if GInput.is_keyboard_player(player_num):
		key_hint.set_frame(split)
	else:
		key_hint.set_frame(4)
	
	GDict.player_data[player_num].team = team_num
	GDict.player_data[player_num].active = true
	
	bg.modulate = GDict.cfg.colors.teams[team_num].lightened(0.75)
	
	remove_area.reset()
	ready_area.reset()

func deactivate():
	bg.set_frame(0)
	remove_area.set_visible(false)
	ready_area.set_visible(false)
	key_hint.set_visible(false)
	is_active = false
	
	GDict.player_data[player_num].active = false
	
	bg.modulate = Color(1,1,1,1)
	
	if player != null:
		player.queue_free()
		player = null

func _on_remove_area_completed():
	GInput.remove_player(player_num)
	deactivate()
	interface_manager.on_player_removed(self)

func _on_ready_area_completed():
	make_ready()

func make_ready():
	is_ready = true
	interface_manager.on_player_ready()
	GAudio.play_static_sound("ui_button")
