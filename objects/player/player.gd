extends RigidDynamicBody2D

@onready var main_node = get_node("/root/Main")

const MOVE_SPEED : float = 280.0
const AGILITY : float = 5.0
var last_input : Vector2 = Vector2.ZERO

var player_num : int = -1
var team_num : int = -1

var can_teleport : bool = false
var field

var speed_factor : float = 1.0
var reverse : bool = false

@onready var shaper = $Shaper
@onready var drawer = $Drawer
@onready var powerups = $Powerups
@onready var sprite = $Sprite2D

@onready var start_freeze_timer = $StartFreezeTimer

func _ready():
	starting_freeze()

func set_data(p_num : int, t_num : int):
	player_num = p_num
	team_num = t_num
	
	sprite.set_frame(GDict.available_faces[p_num])
	shaper.activate()

func handle_input(vec):
	last_input = vec

func _integrate_forces(state):
	var wanted_vel = last_input * get_cur_move_speed()
	var cur_vel = state.linear_velocity
	
	if reverse: wanted_vel *= -1
	
	cur_vel.x = move_toward(cur_vel.x, wanted_vel.x, AGILITY)
	cur_vel.y = move_toward(cur_vel.y, wanted_vel.y, AGILITY)
	
	state.linear_velocity = cur_vel

func change_speed_factor(df):
	speed_factor = clamp(speed_factor + df, 0.4, 1.8)

func get_cur_move_speed():
	return MOVE_SPEED * field.powerups.get_slowdown_factor() * speed_factor

func is_teleportable() -> bool:
	return can_teleport

func starting_freeze():
	can_teleport = false
	start_freeze_timer.start()

func _on_start_freeze_timer_timeout():
	can_teleport = true
