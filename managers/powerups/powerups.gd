extends Node2D

@onready var main_node = get_parent()
@onready var timer : Timer = $Timer
var powerups : Array = []

const TIMER_BOUNDS : Dictionary = { 'min': 7.0, 'max': 17.0 }
const POWERUP_BOUNDS : Dictionary = { 'min': 0, 'max': 2 }

var powerup_scene : PackedScene = preload("res://objects/powerups/powerup.tscn")

func activate():
	restart_timer()

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
	
	var rand_gate = gates[randi() % gates.size()]
	rand_gate.link_powerup(p)

func remove_powerup(p):
	powerups.erase(p)

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
