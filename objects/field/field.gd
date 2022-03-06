extends Node2D

var extents : Vector2 = Vector2.ZERO
var busy_initializing : bool = false
var busy_removing : bool = false

var top_team : int = 0
var bottom_team : int = 1

const FIELD_BOUNDS : Dictionary = { 'min': 220.0, 'max': 350.0 }

# managers
@onready var main_node = get_node("/root/Main")
@onready var field_manager = get_parent()

# modules
@onready var drawer = $Drawer
@onready var score = $Score
@onready var balls = $Balls
@onready var players = $Players
@onready var edges = $Edges
@onready var goaleffects = $GoalEffects
@onready var gates = $Gates

func activate():
	if randf() <= 0.5:
		top_team = 1
		bottom_team = 0
	
	edges.activate()
	
	set_random_width()
	resize()
	
	busy_initializing = true

func post_tween_activate():
	balls.activate()
	players.activate()
	gates.activate()
	
	busy_initializing = false

func get_width() -> float:
	return extents.x

func get_height() -> float:
	return extents.y

func get_size() -> Vector2:
	return extents

func set_random_width():
	var rand_width = randf_range(FIELD_BOUNDS.min, FIELD_BOUNDS.max)
	extents.x = min(rand_width, field_manager.get_max_available_width())

func resize():
	extents.y = field_manager.get_max_height()
	drawer.update()
	edges.update_from_field()
	score.update_from_field()

func get_random_position_inside() -> Vector2:
	var bad_pos : bool = true
	var pos : Vector2
	var num_tries : int = 0
	
	while bad_pos:
		pos = Vector2(
			randf_range(-0.45, 0.45) * extents.x,
			randf_range(-0.45, 0.45) * extents.y
		)
		bad_pos = balls.get_dist_to_closest(pos) <= 50.0 or players.get_dist_to_closest(pos) <= 50.0
		num_tries += 1
		if num_tries > 100.0: bad_pos = false
	
	return pos
