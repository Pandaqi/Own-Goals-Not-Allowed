extends Node2D

@onready var main_node = get_parent()

const PREDEFINED_SHAPE_SCALE : float = 1.0
var available_shapes : Array = []
var predefined_shape_list = preload("res://objects/shapes/predefined_shape_list.tscn")

var teams : Array = [
	[],
	[]
]

func activate():
	load_predefined_shapes()
	cache_team_members()

func cache_team_members():
	for i in range(GInput.get_player_count()):
		var data = GDict.player_data[i]
		teams[data.team].append(i)

func _physics_process(dt):
	poll_input()

func poll_input():
	var all_fields = main_node.field_manager.get_all_fields()
	
	for i in range(GInput.get_player_count()):
		var vec : Vector2 = GInput.get_move_vec(i)
		for f in all_fields:
			if f.busy_initializing: continue
			f.players.give_input(i, vec)

func count_instances_of(p_num : int) -> int:
	var all_fields = main_node.field_manager.get_all_fields()
	var sum : int = 0
	for f in all_fields:
		sum += f.players.count_instances_of(p_num)
	return sum

func get_team(t_num : int):
	return teams[t_num] + []

func get_random_player_num_in_team(t_num : int):
	var list = get_team(t_num)
	return list[randi() % list.size()]

# SHape loading
func load_predefined_shapes():
	var list = predefined_shape_list.instantiate()
	for child in list.get_children():
		if not (child is CollisionPolygon2D): continue
		
		var key = String(child.name).to_lower()
		var val = scale_shape( Array(child.polygon) )
		available_shapes.append(val)
	
	available_shapes.shuffle()

# NOTE: Points are already around centroid, and shaper node will do that again anyway, so just scale only
func scale_shape(points):
	var new_points = []
	for p in points:
		new_points.append(p * PREDEFINED_SHAPE_SCALE)
	return new_points
