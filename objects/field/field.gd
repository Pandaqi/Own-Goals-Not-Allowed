extends Node2D

var extents : Vector2 = Vector2.ZERO
var busy_initializing : bool = false

var top_team : int = 0
var bottom_team : int = 1

# managers
@onready var main_node = get_node("/root/Main")
@onready var field_manager = get_parent()

# modules
@onready var drawer = $Drawer
@onready var score = $Score
@onready var balls = $Balls
@onready var players = $Players
@onready var edges = $Edges

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
	
	busy_initializing = false

func get_width() -> float:
	return extents.x

func get_height() -> float:
	return extents.y

func get_size() -> Vector2:
	return extents

func set_random_width():
	extents.x = min(randi_range(300, 500), field_manager.get_max_available_width())

func resize():
	extents.y = field_manager.get_max_height()
	drawer.update()
	edges.update_from_field()
	score.update_from_field()

func get_random_position_inside() -> Vector2:
	return Vector2(
		randf_range(-0.5, 0.5) * extents.x,
		randf_range(-0.5, 0.5) * extents.y
	)
