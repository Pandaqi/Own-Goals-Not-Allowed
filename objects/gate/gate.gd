extends Node2D

var twin = null
var field

@onready var appear_pos : Node2D = $AppearPos

func link_with(other_node):
	if other_node == null: return
	
	twin = other_node
	other_node.twin = self

	position.y = other_node.position.y

func _on_area_2d_body_entered(body):
	if not body.is_in_group("Players"): return
	if not body.is_teleportable(): return
	
	if field.busy_removing or twin.field.busy_removing: return
	
	field.players.remove_player_by_node(body)
	twin.field.players.call_deferred("add_player", body.player_num, twin.get_appear_pos())

func get_appear_pos():
	return self.position + appear_pos.position.rotated(self.rotation)
