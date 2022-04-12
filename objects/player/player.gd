extends RigidDynamicBody2D

@onready var main_node = get_node("/root/Main")

const BOT_MOVE_SPEED : float = 100.0
const MOVE_SPEED : float = 200.0
const AGILITY : float = 2.0
var last_input : Vector2 = Vector2.ZERO
var velocity_last_frame : Vector2 = Vector2.ZERO

var player_num : int = -1
var team_num : int = -1

var can_teleport : bool = false
var field = null
var body_hit : Vector2 = Vector2.ZERO

var speed_factor : float = 1.0
var reverse : bool = false

var is_bot : bool = false

var busy_removing : bool = false
var busy_adding : bool = false

@onready var shaper = $Shaper
@onready var drawer = $Drawer
@onready var powerups = $Powerups

@onready var start_freeze_timer = $StartFreezeTimer

# ball is anchor point with mass = 1.0 
const PLAYER_MASS : float = 10.0
const BOUNCE_SPEED : Dictionary = { 'min': 50.0, 'max': 400 }
const BOUNCE_MULTIPLIER : Dictionary = { 'min': 1.6, 'max': 3.2 }

func _ready():
	mass = PLAYER_MASS
	starting_freeze()

func set_data(p_num : int, t_num : int):
	player_num = p_num
	team_num = t_num
	
	is_bot = (player_num >= GInput.get_player_count())
	
	shaper.face_sprite.set_frame(GDict.available_faces[p_num])
	shaper.activate()

func initialization_finished():
	busy_adding = false

func is_busy():
	return busy_adding or busy_removing

func flip_reverse():
	reverse = not reverse

func handle_input(vec):
	last_input = vec

func _integrate_forces(state):
	var wanted_vel = last_input * get_cur_move_speed()
	var cur_vel = state.linear_velocity
	
	if reverse: wanted_vel *= -1
	
	var damping = AGILITY
	if wanted_vel.length() <= 0.03: damping = 0.33*AGILITY
	
	cur_vel.x = move_toward(cur_vel.x, wanted_vel.x, damping)
	cur_vel.y = move_toward(cur_vel.y, wanted_vel.y, damping)
	
	state.linear_velocity = cur_vel
	
	if body_hit.length() > 0.03:
		var cur_speed = velocity_last_frame.length()
		var multiplier = randf_range(BOUNCE_MULTIPLIER.min, BOUNCE_MULTIPLIER.max)
		var bounce_speed = clamp(cur_speed * multiplier, BOUNCE_SPEED.min, BOUNCE_SPEED.max)
		var vec_away = (state.transform.origin - body_hit).normalized()
		state.linear_velocity = vec_away * bounce_speed
		body_hit = Vector2.ZERO
	
	velocity_last_frame = state.linear_velocity

func change_speed_factor(df : float):
	speed_factor = clamp(speed_factor + df, 0.4, 1.8)

func get_cur_move_speed():
	if field == null: return MOVE_SPEED
	
	var base_speed = MOVE_SPEED
	if is_bot: base_speed = BOT_MOVE_SPEED
	return base_speed * field.powerups.get_slowdown_factor() * speed_factor

func is_teleportable() -> bool:
	return can_teleport and not is_busy()

func starting_freeze():
	can_teleport = false
	start_freeze_timer.start()

func _on_start_freeze_timer_timeout():
	can_teleport = true

func _on_player_body_entered(body):
	if not (body.is_in_group("Balls") or body.is_in_group("Players")): return
	
	body_hit = body.global_transform.origin
