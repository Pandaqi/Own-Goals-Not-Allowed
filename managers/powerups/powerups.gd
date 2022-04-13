extends Node2D

@onready var main_node = get_parent()
@onready var timer : Timer = $Timer
var powerups : Array = []

const TIMER_BOUNDS : Dictionary = { 'min': 7.0, 'max': 17.0 }
const POWERUP_BOUNDS : Dictionary = { 'min': 0, 'max': 2 }
const DEF_POWERUP_TYPE : String = "remove_opponents"

var powerup_scene : PackedScene = preload("res://objects/powerups/powerup.tscn")
var total_probability : float = 0.0


func activate():
	restart_timer()
	determine_powerup_probabilities()

func determine_powerup_probabilities():
	var all_types = GDict.powerup_types.keys()
	
	total_probability = 0.0
	for tp in all_types:
		var prob = 1
		if GDict.powerup_types[tp].has("prob"):
			prob = GDict.powerup_types[tp].prob
		else:
			GDict.powerup_types[tp].prob = 1
		
		total_probability += prob

func restart_timer():
	timer.wait_time = randf_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func _on_timer_timeout():
	restart_timer()
	place_new_powerup()

func place_new_powerup():
	if powerups.size() >= POWERUP_BOUNDS.max: return
	
	var gates : Array = collect_gates_without_powerup()

	if gates.size() <= 0: return
	
	var p = powerup_scene.instantiate()
	p.powerup_manager = self
	powerups.append(p)
	add_child(p)
	
	p.activate()
	p.set_type(get_random_powerup_type())
	
	var tw = GTween.tween_bounce(p)
	tw.tween_callback(p.finish_creation)
	
	var rand_gate = gates[randi() % gates.size()]
	rand_gate.link_powerup(p)

func remove_powerup(p):
	powerups.erase(p)

func get_random_powerup_type() -> String:
	var all_types = GDict.powerup_types.keys()
	var running_sum : float = 0.0
	var target = randf() * total_probability
	for tp in all_types:
		running_sum += GDict.powerup_types[tp].prob
		if running_sum >= target:
			return tp

	return DEF_POWERUP_TYPE

func collect_gates_without_powerup() -> Array:
	var fields = main_node.field_manager.get_all_fields()
	var list : Array = []
	for f in fields:
		if f.is_busy(): continue
		
		if f.gates.get_gate(0).can_have_powerup():
			list.append(f.gates.get_gate(0))
		
		if f.gates.get_gate(1).can_have_powerup():
			list.append(f.gates.get_gate(1))
	
	return list
