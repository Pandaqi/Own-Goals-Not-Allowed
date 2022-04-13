extends Node2D

@onready var body = get_parent()

@onready var area : Area2D = $Area2D
const ATTRACT_FORCE : float = 350.0
var is_magnet : bool = false

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
		body.shaper.change_size(0.5)
	elif type == 'grow_player':
		body.shaper.change_size(1.5)
	elif type == 'magnet':
		is_magnet = true
	elif type == 'player_unbounce':
		body.enable_extra_bounces = false

func _physics_process(dt):
	handle_magnet(dt)

func handle_magnet(dt):
	if not is_magnet: return
	
	for b in area.get_overlapping_bodies():
		if not b.is_in_group("Balls"): continue
		
		var vec_to_us = (body.global_position - b.global_position).normalized()
		b.apply_central_impulse(vec_to_us * ATTRACT_FORCE * dt)
