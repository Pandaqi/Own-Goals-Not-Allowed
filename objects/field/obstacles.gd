extends Node2D

@onready var field = get_parent()

var nodes = []

const OBSTACLES_FROM_POWERUP : Dictionary = { 'min': 3, 'max': 5 }
const TIMER_BOUNDS : Dictionary = { 'min': 3.0, 'max': 7.0 }
const OBSTACLE_BOUNDS : Dictionary = { 'min': 0, 'max': 5 }

const STARTING_OBSTACLE_PROB : float = 0.25

var obstacle_scene : PackedScene = preload("res://objects/field/obstacles/obstacle.tscn")

@onready var timer : Timer = $Timer

func activate():
	if randf() <= STARTING_OBSTACLE_PROB:
		add_one()
	
	restart_timer()

#
# Removing
#
func remove_one():
	var n = nodes.pop_front()
	var tw = GTween.tween_bounce_reverse(n)
	tw.tween_callback(n.queue_free)

func remove_all():
	while nodes.size() > 0:
		remove_one()
	nodes = []

#
# Adding
#
func add_from_powerup():
	var rand_num = randi_range(OBSTACLES_FROM_POWERUP.min, OBSTACLES_FROM_POWERUP.max)
	for i in range(rand_num):
		add_one()

func add_one():
	if nodes.size() >= OBSTACLE_BOUNDS.max: return
	
	var new_pos = get_random_valid_pos()
	if new_pos == null: return
	
	var o = obstacle_scene.instantiate()
	add_child(o)
	o.set_position(new_pos)
	
	var new_rot = randi_range(0,7) * 0.25 * PI
	o.set_rotation(new_rot)
	
	nodes.append(o)
	
	var tw = GTween.tween_bounce(o)

func get_random_valid_pos():
	var bad_pos : bool = true
	var pos : Vector2
	var num_tries : int = 0
	
	var spawn_props = { 
		'min_dist_to_player': 50,
		'min_dist_to_ball': 50,
		'min_dist_to_obstacle': 30
	}
	
	while bad_pos:
		bad_pos = false
		if num_tries >= 350.0: return null
		
		pos = Vector2(
			randf_range(-0.4, 0.4) * field.extents.x,
			randf_range(-0.25, 0.25) * field.extents.y
		)
		
		if field.players.get_dist_to_closest(pos) <= spawn_props.min_dist_to_player:
			bad_pos = true
			continue
		
		if field.balls.get_dist_to_closest(pos) <= spawn_props.min_dist_to_ball:
			bad_pos = true
			continue
		
		if get_dist_to_closest(pos) <= spawn_props.min_dist_to_obstacle:
			bad_pos = true
			continue
	
	return pos

func get_dist_to_closest(pos : Vector2) -> float:
	var dist : float = 20000.0
	for n in nodes:
		dist = min(dist, (n.position - pos).length())
	
	return dist

#
# Timer
#
func restart_timer():
	timer.wait_time = randf_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func _on_timer_timeout():
	restart_timer()
	
	var remove_prob = nodes.size() / OBSTACLE_BOUNDS.max
	
	if randf() <= remove_prob:
		remove_one()
	else:
		add_one()
