extends Node2D

@onready var body = get_parent()

func grab(node):
	var type = node.type
	
	print("GRABBED POWERUP")
	print(type)
	
	if type == 'move_faster':
		body.change_speed_factor(0.3)
	elif type == 'move_slower':
		body.change_speed_factor(-0.3)
	elif type == 'reverse_controls':
		body.flip_reverse()
	elif type == 'shrink_player':
		body.shaper.call_deferred("shrink", 0.5)
