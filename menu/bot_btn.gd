extends Area2D

@onready var label : Label = $Label

func _ready():
	update_visuals()

func _on_quit_btn_input_event(viewport, event, shape_idx):
	if not (event is InputEventMouseButton): return
	if event.pressed: return
	
	toggle_bots()

func _input(ev):
	if ev is InputEventKey and not ev.pressed and ev.keycode == KEY_SHIFT:
		toggle_bots()

func toggle_bots():
	GDict.cfg.bots = not GDict.cfg.bots
	update_visuals()

func update_visuals():
	var status_text = "Off"
	if GDict.cfg.bots: status_text = "On"
	label.set_text("Add bots?\n" + status_text)
