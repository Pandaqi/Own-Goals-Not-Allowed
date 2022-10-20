extends CanvasLayer

@onready var main_node = get_parent()
@onready var color_rect = $ColorRect

func activate():
	main_node.on_resize.connect(on_resize)

func on_resize(vp):
	color_rect.material.set_shader_parameter("real_size", vp)
