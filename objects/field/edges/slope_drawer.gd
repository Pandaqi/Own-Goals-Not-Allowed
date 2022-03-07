extends Node2D

@onready var body = get_parent()

func _draw():
	var team = body.team
	var color = GDict.cfg.colors.teams[team]
	
	draw_polygon(body.col_node.polygon, [color])
