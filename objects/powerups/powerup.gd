extends Node2D

var powerup_manager
var type : String = ""

var active : bool = false

var linked_fields : Array = []
var pointing_left : bool = false

@onready var main_node = get_node("/root/Main")
@onready var sprite : Sprite2D = $Sprite2D

var powerup_particles : PackedScene = preload("res://objects/powerups/powerup_particle.tscn")

func activate():
	point_to_random_side()

func finish_creation():
	active = true

func set_type(tp : String):
	type = tp
	sprite.set_frame(GDict.powerup_types[tp].frame)

func point_to_random_side():
	pointing_left = false if randf() <= 0.5 else true
	sprite.flip_h = pointing_left # sprite points RIGHT by default

func link_field(f):
	linked_fields.append(f)
	linked_fields.sort_custom(linked_field_sorter)

func linked_field_sorter(a,b):
	return a.global_transform.origin.x < b.global_transform.origin.x

func is_grabbed_by(node):
	var is_field_focused = (GDict.powerup_types[type].focus == 'field')
	if is_field_focused:
		var f = linked_fields[0]
		if not pointing_left: f = linked_fields[1]
		f.powerups.grab(self, node)
	
	var is_player_focused = (GDict.powerup_types[type].focus == 'player')
	if is_player_focused:
		powerup_manager.main_node.players.execute_powerup_for_all(node.player_num, self)
	
	GAudio.play_dynamic_sound(self, "powerup_grab")
	GTween.create_feedback_for_node(self, GDict.powerup_types[type].txt)
	
	var p = powerup_particles.instantiate()
	main_node.add_child(p)
	p.set_position(global_position) 
	
	remove()

func remove():
	powerup_manager.remove_powerup(self)
	
	var tw = GTween.tween_bounce_reverse(self)
	tw.tween_callback(queue_free)
