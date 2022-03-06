extends Node

var version_number : String = "v0.5"
var major_version : String = "alpha"

var cfg = {
	'rescale_viewport': false,
	'predefined_window_size': Vector2(1280, 720),
	
	'num_points_to_win': 1, # DEBUGGING
	'colors': {
		'teams': [
			Color(0,0,1),
			Color(1,0,1)
		],
		'ball': Color(1,0,0)
	}
}

var player_data = [
	{ 'team': 0, 'active': true },
	{ 'team': 1, 'active': true },
	{ 'team': 0, 'active': true },
	{ 'team': 1, 'active': true },
	{ 'team': 0, 'active': true },
	{ 'team': 1, 'active': true },
	{ 'team': 0, 'active': true },
	{ 'team': 1, 'active': true }
]

const PREDEFINED_SHAPE_SCALE : float = 1.0
var available_shapes : Array = []
var predefined_shape_list : PackedScene = preload("res://objects/shapes/predefined_shape_list.tscn")

const NUM_FACES : int = 8
var available_faces : Array = []

func _ready():
	load_faces()
	load_predefined_shapes()

func load_faces():
	for i in range(NUM_FACES):
		available_faces.append(i)
	
	available_faces.shuffle()

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
