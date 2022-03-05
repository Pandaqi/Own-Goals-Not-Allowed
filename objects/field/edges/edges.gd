extends Node2D

const THICKNESS : float = 20.0
const GOAL_WIDTH : float = 100.0

@onready var field = get_parent()

var edge_scene : PackedScene = preload("res://objects/field/edges/single_edge.tscn")
var edges = {
	'top_left': null,
	'top_right': null,
	'left': null,
	'right': null,
	'bottom_left': null,
	'bottom_right': null,
	
	'player_block_top': null,
	'player_block_bottom': null
}

func activate():
	create_edges()

func create_edges():
	for key in edges:
		var e = edge_scene.instantiate()
		add_child(e)
		edges[key] = e
	
	# only react to players, nothing else
	edges.player_block_bottom.make_player_blocking()
	edges.player_block_top.make_player_blocking()

func update_from_field():
	var size = field.get_size()
	var horiz_size : float = 0.5 * (size.x - GOAL_WIDTH)
	var vert_size : float = size.y + THICKNESS # for covering the corners
	
	# set everything to the right sizes (the easy part)
	edges.top_left.set_size(Vector2(horiz_size, THICKNESS))
	edges.top_right.set_size(Vector2(horiz_size, THICKNESS))
	edges.bottom_left.set_size(Vector2(horiz_size, THICKNESS))
	edges.bottom_right.set_size(Vector2(horiz_size, THICKNESS))
	
	edges.left.set_size(Vector2(THICKNESS, vert_size))
	edges.right.set_size(Vector2(THICKNESS, vert_size))
	
	edges.player_block_top.set_size(Vector2(size.x, THICKNESS))
	edges.player_block_bottom.set_size(Vector2(size.x, THICKNESS))
	
	# position them all correctly (the hard part)
	var top_left = -0.5*size
	var top_right = Vector2(0.5*size.x, -0.5*size.y)
	var bottom_right = 0.5*size
	var bottom_left = Vector2(-0.5*size.x, 0.5*size.y)
	
	edges.top_left.position = top_left + 0.5*Vector2.RIGHT*horiz_size
	edges.top_right.position = top_right - 0.5*Vector2.RIGHT*horiz_size
	edges.bottom_left.position = bottom_left + 0.5*Vector2.RIGHT*horiz_size
	edges.bottom_right.position = bottom_right - 0.5*Vector2.RIGHT*horiz_size
	
	edges.left.position = Vector2(top_left.x, 0)
	edges.right.position = Vector2(top_right.x, 0)
	
	edges.player_block_top.position = 0.5 * (top_left + top_right)
	edges.player_block_bottom.position = 0.5 * (bottom_left + bottom_right)
	
	# give them their teams
	edges.top_left.set_team(field.top_team)
	edges.top_right.set_team(field.top_team)
	edges.player_block_top.set_team(field.top_team)
	
	# (or give multiple teams if they span both boxes)
	edges.left.set_team([field.top_team, field.bottom_team])
	edges.right.set_team([field.top_team, field.bottom_team])
	
	edges.bottom_left.set_team(field.bottom_team)
	edges.bottom_right.set_team(field.bottom_team)
	edges.player_block_bottom.set_team(field.bottom_team)
