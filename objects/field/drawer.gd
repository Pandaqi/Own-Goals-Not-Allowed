extends Node2D

@onready var body = get_parent()
@onready var shadow = get_node("../Shadow")
@export var grass_color : Color

const GOAL_RECT_ALPHA = 1.0

const CORNER_CIRCLE_RADIUS : float = 50.0
const MARKINGS_COLOR : Color = Color(1,1,1)
const MARKINGS_SIZE : float = 5.0

func _draw():
	var size = body.get_size()
	
	# set the shadow to the right size
	shadow.set_scale((size + Vector2.ONE*30) / Vector2(192, 256))
	
	# draw the rectangle underneath
	var rect = Rect2(-0.5*size, size)
	draw_rect(rect, grass_color, true)
	
	# draw stripes over it
	var num_stripes : int = 8
	var stripe_height : float = size.y / float(num_stripes*2)
	
	var stripe_pos = -0.5*size
	var stripe_size = Vector2(size.x, stripe_height)
	var dark_grass = grass_color.darkened(0.16)
	for i in range(num_stripes):
		rect = Rect2(stripe_pos, stripe_size)
		draw_rect(rect, dark_grass)
		
		stripe_pos.y += stripe_size.y*2
	
	#
	# draw white markings over it (like a real soccer field)
	#
	
	# corner circles
	var corners = [
		-0.5*size,
		Vector2(0.5*size.x, -0.5*size.y),
		0.5*size,
		Vector2(-0.5*size.x, 0.5*size.y)
	]
	
	for i in range(4):
		var pos = corners[i]
		var ang = i*0.5*PI
		draw_arc(pos, CORNER_CIRCLE_RADIUS, ang, ang + 0.5*PI, 10, MARKINGS_COLOR, MARKINGS_SIZE)
	
	#
	# middle line
	#
	draw_line(Vector2(-0.5*size.x, 0), Vector2(0.5*size.x, 0), MARKINGS_COLOR, MARKINGS_SIZE)
	
	#
	# keeper area
	#
	var goal_size = body.edges.GOAL_WIDTH
	var keeper_margin = 50
	var mid_top = Vector2(0, -0.5*size.y)
	var area_size = Vector2(goal_size + keeper_margin, 0.5*goal_size)
	var rect_0 = Rect2(mid_top - Vector2(0.5*area_size.x, 0), area_size)
	
	var mid_bottom = Vector2(0, 0.5*size.y)
	var rect_1 = Rect2(mid_bottom - Vector2(0.5*area_size.x, area_size.y), area_size)
	
	draw_rect(rect_0, MARKINGS_COLOR, false, MARKINGS_SIZE)
	draw_rect(rect_1, MARKINGS_COLOR, false, MARKINGS_SIZE)
