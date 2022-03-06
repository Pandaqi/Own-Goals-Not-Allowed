extends Node2D

var powerup_manager
var type : String = ""

var linked_fields : Array = []
var pointing_left : bool = false

@onready var sprite : Sprite2D = $Sprite2D

func activate():
	set_random_type()
	point_to_random_side()

func set_random_type():
	type = GDict.powerup_types.keys()[randi() % GDict.powerup_types.size()]
	sprite.set_frame(GDict.powerup_types[type].frame)

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
	
	remove()

func remove():
	powerup_manager.remove_powerup(self)
	self.queue_free()
