extends Area2D

var count : bool = false
var num : float = 0.0

@onready var sprite : Sprite2D = $Sprite2D
@export var reverse : bool = false
var is_done : bool = false

signal completed()

func _ready():
	sprite.material = sprite.material.duplicate(true)
	sprite.material.set_shader_param("reverse", reverse)

func reset():
	is_done = false
	count = false
	num = 0.0
	update_visuals()

func _on_remove_area_body_entered(body):
	if not body.is_in_group("Players"): return
	count = true

func _on_remove_area_body_exited(body):
	if not body.is_in_group("Players"): return
	if is_done: return
	reset()

func _physics_process(dt):
	if is_done: return
	if not count: return
	
	num += dt
	update_visuals()
	
	if num >= 1.0:
		is_done = true
		emit_signal("completed")

func update_visuals():
	sprite.material.set_shader_param("num", num)
