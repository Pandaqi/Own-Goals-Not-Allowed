extends Node2D

@onready var main_node = get_parent()

var active : bool = false
var tween = null

func _ready():
	set_visible(false)
	active = false

func activate():
	tween = main_node.field_manager.hide_all_fields()
	tween.tween_callback(finish_activation)

func finish_activation():
	set_visible(true)
	active = true
	get_tree().paused = true

func deactivate():
	set_visible(false)
	get_tree().paused = false
	
	tween = main_node.field_manager.show_all_fields()
	tween.tween_callback(finish_deactivation)

func finish_deactivation():
	active = false

func toggle():
	if tween != null and tween.is_running(): return
	
	if active: deactivate()
	else: activate()

func _input(ev):
	if main_node.gameover.has_been_triggered(): return
	
	if ev.is_action_released("toggle_pause_menu"):
		toggle()
	
	if not active: return
	
	if ev.is_action_released("pause_menu_exit"):
		get_tree().paused = false
		pass # TO DO: exit to main menu/input select
	
	elif ev.is_action_released("pause_menu_restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()
