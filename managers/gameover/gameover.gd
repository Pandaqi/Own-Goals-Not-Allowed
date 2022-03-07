extends CanvasLayer

@onready var main_node = get_parent()
@onready var container = $Container
@onready var winner_label = $Container/Winner

var confetti_particles : PackedScene = preload("res://objects/field/goaleffects/confetti_particles.tscn")

var winning_team_num : int = -1
var active : bool = false
var triggered : bool = false

func activate():
	container.set_visible(false)
	
	main_node.on_resize.connect(on_resize)

func on_resize(vp):
	container.set_position(0.5 * vp)

func has_been_triggered() -> bool:
	return triggered

func game_over(winning_team : int):
	if has_been_triggered(): return
	
	winning_team_num = winning_team
	triggered = true
	
	main_node.field_manager.remove_all_fields()
	
	GAudio.play_static_sound("gameover")
	
	# create two confettis, one rotated upside down, to get a full circle of confetti!
	for i in range(2):
		var c = confetti_particles.instantiate()
		main_node.score.add_child(c)
		c.set_scale(Vector2.ONE*3)
		c.set_position(0.5*get_viewport().size)
		
		if i == 1: c.set_rotation(PI)

	print("GAME OVER; team " + str(winning_team) + " won")

func _on_fields_no_fields_to_rearrange():
	finalize_game_over()

func finalize_game_over():
	if winning_team_num < 0: return
	
	container.set_visible(true)
	winner_label.modulate = GDict.cfg.colors.teams[winning_team_num].lightened(0.3)
	winner_label.set_text("Team " + str(winning_team_num + 1) + " won!")
	
	active = true

func _input(ev):
	if not active: return
	
	if ev.is_action_released("game_over_restart"):
		get_tree().reload_current_scene()
	
	elif ev.is_action_released("game_over_back"):
		pass
		
		# TO DO: change scene to main menu/input select => get_tree().change_scene_to()
