extends Node

var version_number : String = "v0.5"
var major_version : String = "alpha"

var cfg = {
	'rescale_viewport': false,
	'predefined_window_size': Vector2(1280, 720),
	
	'num_points_to_win': 100,
	'colors': {
		'teams': [
			Color(0,0,1),
			Color(1,0,1)
		],
		'ball': Color(0,0,0)
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

var powerup_types = {
	"remove_all": { 'focus': 'field', 'frame': 0 },
	"remove_opponents": { 'focus': 'field', 'frame': 1 },
	"add_ball": { 'focus': 'field', 'frame': 2 },
	"ball_five": { 'focus': 'field', 'frame': 3 },
	"ball_double": { 'focus': 'field', 'frame': 4 },
	"full_slowdown": { 'focus': 'field', 'frame': 5 },
	"shrink_goals": { 'focus': 'field', 'frame': 6 },
	"grow_goals": { 'focus': 'field', 'frame': 7 },
	"reverse_goal_dir": { 'focus': 'field', 'frame': 8 },
	
	"move_faster": { 'focus': 'player', 'frame': 9 },
	"move_slower": { 'focus': 'player', 'frame': 10 },
	"reverse_controls": { 'focus': 'player', 'frame': 11 },
	
	"ball_extra_bouncy": { 'focus': 'field', 'frame': 12 },
	"ball_small": { 'focus': 'field', 'frame': 13 },
	"shrink_all": { 'focus': 'field', 'frame': 14 },
	
	"shrink_player": { 'focus': 'player', 'frame': 15 },
}

var ball_types = {
	'regular': { 'frame': 0 },
	'five': { 'frame': 1 },
	'double': { 'frame': 2 },
	'extra_bouncy': { 'frame': 3 },
	'small': { 'frame': 4 }
}

const PREDEFINED_SHAPE_SCALE : float = 1.0
var available_shapes : Array = []
var predefined_shape_list : PackedScene = preload("res://objects/shapes/predefined_shape_list.tscn")

const NUM_FACES : int = 8
var available_faces : Array = []

func _ready():
	load_faces()
	load_predefined_shapes()
	determine_team_colors()

func determine_team_colors():
	var hue = randf()
	var saturation = 0.75
	var luminance = 0.75
	
	var col_0 = Color.from_hsv(hue, saturation, luminance)
	var col_1 = Color.from_hsv(hue+0.5, saturation, luminance)
	
	cfg.colors.teams[0] = col_0
	cfg.colors.teams[1] = col_1

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
func scale_shape(points, val : float = PREDEFINED_SHAPE_SCALE):
	var new_points = []
	for p in points:
		new_points.append(p * val)
	return new_points
