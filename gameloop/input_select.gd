extends Node2D

signal on_resize(size)

var RESCALING_VIEWPORT : bool = GDict.cfg.rescale_viewport
var PREDEFINED_WINDOW_SIZE : Vector2 = GDict.cfg.predefined_window_size

func _ready():
	randomize()
	
	get_viewport().size_changed.connect(on_viewport_changed)
	on_viewport_changed()

func on_viewport_changed():
	var size = PREDEFINED_WINDOW_SIZE
	if RESCALING_VIEWPORT: size = get_viewport().size
	emit_signal("on_resize", size)
