extends Node

var version_number : String = "v0.5"
var major_version : String = "alpha"

var cfg = {
	'rescale_viewport': false,
	'predefined_window_size': Vector2(1280, 720),
	
	'num_points_to_win': 100,
	'bots': false,
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
	"remove_all": { 'focus': 'field', 'frame': 0, "prob": 0.5, "txt": "Destroy All" },
	"remove_opponents": { 'focus': 'field', 'frame': 1.0, "txt": "Destroy Others" },
	"add_ball": { 'focus': 'field', 'frame': 2, "prob": 2.0, "txt": "Extra Ball" },
	"ball_five": { 'focus': 'field', 'frame': 3, "prob": 2.0, "txt": "Five Ball" },
	"ball_double": { 'focus': 'field', 'frame': 4, "prob": 2.0, "txt": "x2 Ball" },
	"full_slowdown": { 'focus': 'field', 'frame': 5, "prob": 0.5, "txt": "Slowdown" },
	"shrink_goals": { 'focus': 'field', 'frame': 6, "prob": 0.5, "txt": "Smaller Goals" },
	"grow_goals": { 'focus': 'field', 'frame': 7, "prob": 2.0, "txt": "Bigger Goals" },
	"reverse_goal_dir": { 'focus': 'field', 'frame': 8, "prob": 2.0, "txt": "Switch Sides" },
	
	"move_faster": { 'focus': 'player', 'frame': 9, "prob": 1.0, "txt": "Faster" },
	"move_slower": { 'focus': 'player', 'frame': 10, "prob": 0.5, "txt": "Slower" },
	"reverse_controls": { 'focus': 'player', 'frame': 11, "prob": 0.5, "txt": "Reverse" },
	
	"ball_extra_bouncy": { 'focus': 'field', 'frame': 12, "prob": 0.5, "txt": "Bouncy Ball" },
	"ball_small": { 'focus': 'field', 'frame': 13, "prob": 2.0, "txt": "Small Ball" },
	
	"shrink_all": { 'focus': 'field', 'frame': 14, "prob": 1.5, "txt": "Shrink All" },
	"shrink_player": { 'focus': 'player', 'frame': 15, "prob": 1.0, "txt": "Shrink" },
	
	"grow_all": { 'focus': 'field', 'frame': 16, 'prob': 0.75, 'txt': 'Grow All' },
	'grow_player': { 'focus': 'player', 'frame': 17, 'prob': 1.5, 'txt': 'Grow' },
	
	'ball_not_bouncy': { 'focus': 'field', 'frame': 18, 'prob': 1.0, 'txt': 'Unbouncy Ball' },
	'magnet': { 'focus': 'player', 'frame': 19, 'prob': 1.25, 'txt': 'Magnet' },
	'player_unbounce': { 'focus': 'player', 'frame': 20, 'prob': 0.75, 'txt': "No Bounces" },
	'add_obstacles': { 'focus': 'field', 'frame': 21, 'prob': 1.0, 'txt': "+ Obstacles" },
	'remove_obstacles': { 'focus': 'field', 'frame': 22, 'prob': 2.0, 'txt': "- Obstacles" }
}

var ball_types = {
	'regular': { 'frame': 0 },
	'five': { 'frame': 1 },
	'double': { 'frame': 2 },
	'extra_bouncy': { 'frame': 3 },
	'small': { 'frame': 4 },
	'not_bouncy': { 'frame': 5 }
}

const PREDEFINED_SHAPE_SCALE : float = 0.5
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
