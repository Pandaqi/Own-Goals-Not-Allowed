extends Node2D

@export var scene_to_load : PackedScene
@onready var container = $Node2D

#func _input(ev):
#	if ev is InputEventKey and ev.scancode == KEY_SPACE and not ev.pressed:
#		$AnimationPlayer.play("PandaqiBoot")

func _ready():
	container.set_position(0.5*get_viewport().size)

func on_anim_done():
	get_tree().change_scene_to(scene_to_load)
