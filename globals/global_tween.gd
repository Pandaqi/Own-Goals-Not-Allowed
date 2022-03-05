extends Node

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

func tween_goal_effect(node):
	var tw = tween_bounce(node)
	
	var new_mod = Color(1,1,1,0)
	tw.tween_property(node, "modulate", new_mod, 3.0)
	tw.tween_property(node, "visible", false, 0.1)
	
	return tw
