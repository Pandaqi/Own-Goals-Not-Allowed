extends Node2D

@onready var main_node = get_parent()

const NUM_STARTING_FIELDS : int = 2
const PADDING : Vector2 = Vector2(40, 40)
const PADDING_BETWEEN_FIELDS : float = 40.0

var cur_width : float = 0.0
var fields : Array = []

var field_scene : PackedScene = preload("res://objects/field/field.tscn")

func activate():
	get_viewport().size_changed.connect(on_resize)
	on_resize()
	
	create_starting_fields()

func on_resize():
	for f in fields:
		f.resize()
	
	rearrange_fields()

func create_starting_fields():
	for i in range(NUM_STARTING_FIELDS):
		add_field()

func add_field():
	var f = field_scene.instantiate()
	fields.append(f)
	add_child(f)
	
	f.activate()
	cur_width += f.get_width()
	
	play_bouncy_tween(f)
	
	rearrange_fields()

func remove_field():
	var f = fields.pop_back()
	
	cur_width -= f.get_width()
	
	play_bouncy_tween(f)

func rearrange_fields():
	self.set_position(0.5 * get_viewport().size)
	
	# first value to offset the full width
	# second value to compensate that the field anchor point is in its _center_
	var x_pos : float = -0.5*get_cur_total_width()
	for f in fields:
		x_pos += 0.5*f.get_width()
		f.set_position(Vector2(x_pos, 0))
		x_pos += 0.5*f.get_width() + PADDING_BETWEEN_FIELDS
		

func get_max_height() -> float:
	return get_viewport().size.y - 2*PADDING.y

func get_max_width() -> float:
	return get_viewport().size.x - 2*PADDING.x

func get_cur_total_width() -> float:
	return cur_width + (fields.size() - 1)*PADDING_BETWEEN_FIELDS

func get_max_available_width() -> float:
	return get_max_width() - get_cur_total_width()

func update_global_scores():
	main_node.score.update_for(0, get_aggregate_score_for(0))
	main_node.score.update_for(1, get_aggregate_score_for(1))

func get_aggregate_score_for(team_num : int) -> int:
	var sum : int = 0
	for f in fields:
		sum += f.score.get_for(team_num)
	return sum

func get_all_fields() -> Array:
	return fields + []

func play_bouncy_tween(node, is_reveal : bool = true):
	node.set_scale(Vector2.ZERO)
	
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2(1.2, 0.8), 0.2)
	tw.tween_property(node, "scale", Vector2(0.9, 1.1), 0.2)
	tw.tween_property(node, "scale", Vector2.ONE, 0.1)
	
	if is_reveal:
		tw.tween_callback(node.post_tween_activate)
	
	else:
		tw.tween_callback(func(): node.queue_free())
		tw.tween_callback(rearrange_fields)
