extends Node

var feedback_scene = preload("res://objects/powerups/feedback_text.tscn")

func create_feedback_for_node(node, txt : String):
	create_feedback_at(node.get_global_transform_with_canvas().origin, txt)

func create_feedback_at(pos : Vector2, txt : String):
	var f = feedback_scene.instantiate()
	f.get_node("LabelContainer/Label").set_text(txt)
	get_node("/root/Main/Score").add_child(f)
	f.set_position(pos)

func tween_label(node):
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2(1.2, 0.8), 0.15)
	tw.tween_property(node, "scale", Vector2(0.9, 1.1), 0.15)
	tw.tween_property(node, "scale", Vector2.ONE, 0.07)
	
	var mod = node.modulate
	var new_mod = mod.lightened(0.4)
	
	tw = get_tree().create_tween()
	tw.tween_property(node, "modulate", new_mod, 0.3)
	tw.tween_property(node, "modulate", mod, 0.2)
	
	return tw

func tween_bounce(node):
	node.set_scale(Vector2.ZERO)
	
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2(1.2, 0.8), 0.2)
	tw.tween_property(node, "scale", Vector2(0.9, 1.1), 0.2)
	tw.tween_property(node, "scale", Vector2.ONE, 0.1)
	
	return tw

func tween_bounce_reverse(node):
	node.set_scale(Vector2.ONE)
	
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2(1.2, 0.8), 0.1)
	tw.tween_property(node, "scale", Vector2(0.5, 1.5), 0.1)
	tw.tween_property(node, "scale", Vector2.ZERO, 0.2)
	
	return tw

func tween_goal_effect(node):
	var tw = tween_bounce(node)
	
	var new_mod = Color(1,1,1,0)
	tw.tween_property(node, "modulate", new_mod, 3.0)
	tw.tween_property(node, "visible", false, 0.1)
	
	return tw
