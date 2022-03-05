extends Node2D

@onready var main_node = get_parent()

const LABEL_PADDING : float = 100.0
const TARGET_TO_WIN : int = 50

var scores : Array = [0,0]
@onready var score_labels = [
	$ScoreLabel1,
	$ScoreLabel2
]

func activate():
	color_labels()
	
	get_viewport().size_changed.connect(on_resize)
	on_resize()

func on_resize():
	var vp = get_viewport().size
	score_labels[0].set_position(Vector2(LABEL_PADDING, 0.5*vp.y))
	score_labels[1].set_position(Vector2(vp.x - LABEL_PADDING, 0.5*vp.y))

func color_labels():
	for i in range(2):
		score_labels[i].modulate = GDict.cfg.colors.teams[i].lightened(0.5)

func update_for(team_num : int, val : int):
	var nothing_changed = val == scores[team_num]
	if nothing_changed: return
	
	scores[team_num] = val
	
	var label = score_labels[team_num]
	var new_val = str(val)

	label.get_node("Label").set_text(new_val)
	GTween.tween_label(score_labels[team_num])

	if val >= TARGET_TO_WIN:
		main_node.gameover.game_over(team_num)
