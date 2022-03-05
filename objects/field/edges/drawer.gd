extends Node2D

@onready var body = get_parent()

func _draw():
	if body.player_blocking: return
	
	var size = body.col_shape.size
	var team = body.team
	
	if team is Array:
		var rect_0 = Rect2(-0.5*size, Vector2(size.x, 0.5*size.y))
		var rect_1 = Rect2(Vector2(-0.5*size.x, 0), Vector2(size.x, 0.5*size.y))
		
		draw_rect(rect_0, GDict.cfg.colors.teams[team[0]])
		draw_rect(rect_1, GDict.cfg.colors.teams[team[1]])
		
	else:
		var rect = Rect2(-0.5*size, size)
		var color = GDict.cfg.colors.teams[team]
		draw_rect(rect, color, true)
