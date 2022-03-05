extends Node2D

@onready var own_goal_label = $OwnGoal
@onready var goal_label = $Goal

var confetti_particles = preload("res://objects/field/goaleffects/confetti_particles.tscn")

func _ready():
	goal_label.set_visible(false)
	own_goal_label.set_visible(false)

func execute(creator, own_goal : bool = false):
	var pos = creator.global_transform.origin

	var c = confetti_particles.instantiate()
	add_child(c)
	c.global_transform.origin = pos
	
	# bottom needs to be rotated 180 degrees to point inwards to field
	if creator.position.y > 0:
		c.set_rotation(PI)
	
	# tween the label
	var node = goal_label
	if own_goal: node = own_goal_label
	
	node.set_visible(true)
	node.modulate.a = 1.0
	GTween.tween_goal_effect(node)
