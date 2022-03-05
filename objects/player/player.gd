extends RigidDynamicBody2D

@onready var main_node = get_node("/root/Main")

const MOVE_SPEED : float = 280.0
const AGILITY : float = 5.0
var last_input : Vector2 = Vector2.ZERO

var player_num : int = -1
var team_num : int = -1

@onready var shaper = $Shaper
@onready var drawer = $Drawer

func _ready():
	shaper.activate()

func handle_input(vec):
	last_input = vec

func _integrate_forces(state):
	var wanted_vel = last_input * MOVE_SPEED
	var cur_vel = state.linear_velocity
	
	cur_vel.x = move_toward(cur_vel.x, wanted_vel.x, AGILITY)
	cur_vel.y = move_toward(cur_vel.y, wanted_vel.y, AGILITY)
	
	state.linear_velocity = cur_vel
