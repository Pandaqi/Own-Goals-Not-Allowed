extends Node2D

@onready var body = get_parent()

func grab(node):
	var type = node.type
	
	if type == 'move_faster':
		body.change_speed_factor(0.3)
	elif type == 'move_slower':
		body.change_speed_factor(-0.3)
	elif type == 'reverse_controls':
		body.reverse = not body.reverse
	
	# TO DO: implement what all the different powerups do
