extends CanvasLayer

@onready var color_rect = $ColorRect

func activate():
	get_viewport().size_changed.connect(on_resize)
	on_resize()

func on_resize():
	var vp = get_viewport().size
	color_rect.material.set_shader_param("real_size", vp)
