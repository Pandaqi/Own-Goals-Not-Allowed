extends Camera2D

@onready var main_node = get_parent()
var wanted_position : Vector2

const MOVE_SPEED : float = 13.0

func activate():
	main_node.on_resize.connect(on_resize)

func on_resize(vp):
	wanted_position = 0.5 * vp

func focus_on_fields(left : float, right : float):
	var left_pos = Vector2(left, position.y)
	var right_pos = Vector2(right, position.y)
	
	wanted_position = 0.5*(left_pos + right_pos)

func _physics_process(dt):
	if main_node.gameover.has_been_triggered(): return
	
	position = position.lerp(wanted_position, MOVE_SPEED * dt)
