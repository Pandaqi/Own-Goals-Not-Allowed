extends Node2D

@onready var label = $Label

func set_value(v : int):
	label.set_text(str(v))
	
	GTween.tween_label(self)
