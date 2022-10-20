extends Node2D

@onready var main_node = get_parent()

const NUM_STARTING_FIELDS : Dictionary = { 'min': 1, 'max': 2 }
const PADDING : Vector2 = Vector2(40, 40)
const PADDING_BETWEEN_FIELDS : float = 40.0

var fields : Array = []
var cur_vp : Vector2

var field_scene : PackedScene = preload("res://objects/field/field.tscn")

signal no_fields_to_rearrange()

func pre_activate():
	main_node.on_resize.connect(on_resize)

func activate():
	create_starting_fields()

func on_resize(vp):
	cur_vp = vp
	
	for f in fields:
		f.resize()
	
	rearrange_fields()

func create_starting_fields():
	var num_starting_fields : int = randi_range(NUM_STARTING_FIELDS.min, NUM_STARTING_FIELDS.max)
	for i in range(num_starting_fields):
		add_field()

func add_field():
	var f = field_scene.instantiate()
	add_child(f)
	
	f.activate()
	
	var left_edge = calculate_left_edge()
	var right_edge = calculate_right_edge()
	
	if fields.size() <= 0:
		f.set_position(Vector2.ZERO)
	
	else:
		var place_left : bool = false
		if randf() <= 0.5: place_left = true
		
		if place_left: f.set_position(Vector2(left_edge - 0.5*f.extents.x, 0))
		else: f.set_position(Vector2(right_edge + 0.5*f.extents.x, 0))
	
	fields.append(f)
	
	sort_fields_horizontally()
	play_bouncy_tween(f)
	GAudio.play_dynamic_sound(f, "field_change")
	
	rearrange_fields()

func remove_field_at_edge():
	if randf() <= 0.5:
		remove_field(fields[0])
	else:
		remove_field(fields[fields.size() - 1])

func remove_field(node):
	fields.erase(node)
	node.gates.on_removal()
	node.busy_removing = true
	
	GAudio.play_dynamic_sound(node, "field_change")
	play_bouncy_tween(node, false)
	
	sort_fields_horizontally()
	rearrange_fields()
	
	main_node.score.save_perma_score(0, node.score.get_score(0))
	main_node.score.save_perma_score(1, node.score.get_score(1))
	update_global_scores()
	
	main_node.players.handle_players_without_character()

func get_random_field():
	if fields.size() <= 0: return null
	return fields[randi() % fields.size()]

func sort_fields_horizontally():
	fields.sort_custom(horizontal_field_sort)
	
	print("SORTING")
	for f in fields:
		print(f.position.x)

func horizontal_field_sort(a,b):
	return a.position.x < b.position.x

func find_furthest_field(dir):
	var dist : float = -dir * INF
	var field
	
	for f in fields:
		var cur_dist = f.position.length()
		if dir < 0 and cur_dist > dist: continue
		if dir > 0 and cur_dist < dist: continue
		
		dist = cur_dist
		field = f
	
	return field

func rearrange_fields():
	if fields.size() <= 0: 
		emit_signal("no_fields_to_rearrange")
		return
	
	main_node.camera.focus_on_fields(calculate_left_edge(), calculate_right_edge())

func relink_all_gates():
	print("RELINKING GATES")
	for f in fields:
		f.gates.relink_gates()

func calculate_left_edge():
	if fields.size() <= 0: return 0
	return fields[0].position.x - 0.5*fields[0].extents.x - PADDING_BETWEEN_FIELDS

func calculate_right_edge():
	if fields.size() <= 0: return 0
	var idx = fields.size() - 1
	return fields[idx].position.x + 0.5*fields[idx].extents.x + PADDING_BETWEEN_FIELDS

func old_rearrange_fields():
	self.set_position(0.5 * cur_vp)
	
	# first value to offset the full width
	# second value to compensate that the field anchor point is in its _center_
	var x_pos : float = -0.5*get_cur_total_width()
	for f in fields:
		x_pos += 0.5*f.get_width()
		f.set_position(Vector2(x_pos, 0))
		x_pos += 0.5*f.get_width() + PADDING_BETWEEN_FIELDS

func get_max_height() -> float:
	return cur_vp.y - 2*PADDING.y

func get_max_width() -> float:
	return cur_vp.x - 2*PADDING.x

func get_cur_total_width() -> float:
	return (calculate_right_edge() - calculate_left_edge())

func get_max_available_width() -> float:
	return get_max_width() - get_cur_total_width()

func update_global_scores():
	if main_node.gameover.has_been_triggered(): return
	
	main_node.score.update_for(0, get_aggregate_score_for(0))
	main_node.score.update_for(1, get_aggregate_score_for(1))

func get_aggregate_score_for(team_num : int) -> int:
	var sum : int = 0
	for f in fields:
		sum += f.score.get_for(team_num)
	return sum

func count() -> int:
	return fields.size()

func get_all_fields() -> Array:
	return fields + []

func remove_all_fields():
	while fields.size() > 0:
		remove_field(fields[0])

func show_all_fields():
	var tw = get_tree().create_tween()
	for f in fields:
		tw.tween_property(f, "modulate", Color(1,1,1,1), 0.16)
	var powerups = main_node.powerups.get_all()
	for p in powerups:
		tw.tween_property(p, "modulate", Color(1,1,1,1), 0.16)
	return tw

func hide_all_fields():
	var tw = get_tree().create_tween()
	for f in fields:
		tw.tween_property(f, "modulate", Color(1,1,1,0), 0.16)
	var powerups = main_node.powerups.get_all()
	for p in powerups:
		tw.tween_property(p, "modulate", Color(1,1,1,0), 0.16)
	return tw

func play_bouncy_tween(node, is_reveal : bool = true):
	var start_scale = Vector2.ZERO
	var end_scale = Vector2.ONE
	if not is_reveal:
		start_scale = Vector2.ONE
		end_scale = Vector2.ZERO
	
	node.set_scale(start_scale)
	
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2(1.2, 0.8), 0.2)
	tw.tween_property(node, "scale", Vector2(0.9, 1.1), 0.2)
	tw.tween_property(node, "scale", end_scale, 0.1)
	
	if is_reveal:
		tw.tween_callback(node.post_tween_activate)
		tw.tween_callback(self.relink_all_gates)
	
	else:
		tw.tween_callback(func(): node.queue_free())
		tw.tween_callback(rearrange_fields)
		tw.tween_callback(self.relink_all_gates)

func scored_in_goal(team_num : int, ball, own_goal : bool):
	if main_node.gameover.has_been_triggered(): return
	if not own_goal: return
	
	var add_field_prob = 1.0 / (fields.size() - 0.5)
	
	if fields.size() <= 1: add_field_prob = 1.0
	if get_max_available_width() < 250: add_field_prob = 0.0
	
	if randf() <= add_field_prob:
		add_field()
	else:
		remove_field_at_edge()
