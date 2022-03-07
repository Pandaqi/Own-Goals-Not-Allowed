extends Area2D

func _on_quit_btn_input_event(viewport, event, shape_idx):
	if not (event is InputEventMouseButton): return
	if event.pressed: return
	
	quit_game()

func _input(ev):
	if ev is InputEventKey and not ev.pressed and ev.keycode == KEY_ESCAPE:
		quit_game()

func quit_game():
	get_tree().quit()
