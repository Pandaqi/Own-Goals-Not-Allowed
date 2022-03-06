extends Node2D

@onready var field = get_parent()

# gate left, gate right
var gates : Array = []
var gate_scene : PackedScene = preload("res://objects/gate/gate.tscn")

func activate():
	create_gates()
	relink_gates()

func create_gates():
	var offset = 0.5 * field.get_width() - 0.5*field.edges.THICKNESS
	
	for i in range(2):
		var g = gate_scene.instantiate()
		g.position.x = (2*i-1)*offset
		if i == 1: g.rotation = PI
		g.field = field
		add_child(g)
		gates.append(g)

func get_gate(num : int):
	if num < 0 or num >= gates.size(): return null
	return gates[num]

func relink_gates():
	if gates.size() <= 0: return
	
	var fields = field.field_manager.get_all_fields()
	var num_fields = fields.size()
	
	var my_index = fields.find(field)
	var left_nb = fields[ (my_index - 1 + num_fields) % num_fields ]
	var right_nb = fields[ (my_index + 1) % num_fields ]
	
	# TO DO: actually position them on the Y-axis
	gates[0].position.y = get_random_height()
	gates[1].position.y = get_random_height()
	
	gates[0].link_with(left_nb.gates.get_gate(1))
	gates[1].link_with(right_nb.gates.get_gate(0))

func get_random_height() -> float:
	return (randf() - 0.5)*field.get_height() * 0.8 # ( shrink to ensure easily accessible from field)
