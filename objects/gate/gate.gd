extends Node2D

var twin = null
var field
var linked_powerup = null

@onready var appear_pos : Node2D = $AppearPos

func link_with(other_node):
	if other_node == null: return
	
	twin = other_node
	other_node.twin = self

func _on_area_2d_body_entered(body):
	if not body.is_in_group("Players"): return
	if not body.is_teleportable(): return
	
	if field.busy_removing or twin.field.busy_removing: return
	
	if not has_no_powerup():
		linked_powerup.is_grabbed_by(body)
		remove_powerup()
		twin.remove_powerup()
	
	field.players.remove_player_by_node(body)
	twin.field.players.call_deferred("add_player", body.player_num, twin.get_appear_pos())

func update_position(y_pos : float):
	self.position.y = y_pos
	if twin != null: twin.position.y = y_pos
	update_powerup_position()

func get_appear_pos():
	return self.position + appear_pos.position.rotated(self.rotation)

func has_no_powerup() -> bool:
	return linked_powerup == null or not is_instance_valid(linked_powerup)

func can_have_powerup() -> bool:
	if field.is_left_field() and field.gates.get_gate(0) == self: return false
	if field.is_right_field() and field.gates.get_gate(1) == self: return false
	if not has_no_powerup(): return false
	return true

func link_powerup(node):
	linked_powerup = node
	twin.linked_powerup = node
	
	node.link_field(self.field)
	node.link_field(twin.field)
	
	update_powerup_position()

func update_powerup_position():
	if has_no_powerup(): return 
	
	var our_pos = self.global_transform.origin
	var their_pos = twin.global_transform.origin
	linked_powerup.global_transform.origin = 0.5 * (our_pos + their_pos) 

func remove_powerup():
	linked_powerup = null

func destroy_powerup():
	if has_no_powerup(): return 
	linked_powerup.remove()
