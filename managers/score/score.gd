extends CanvasLayer

@onready var main_node = get_parent()

const LABEL_PADDING : float = 100.0

var perma_scores : Array = [0,0]
var scores : Array = [0,0]
@onready var score_labels = [
	$ScoreLabel1,
	$ScoreLabel2
]

func activate():
	color_labels()
	
	main_node.on_resize.connect(on_resize)

func on_resize(vp):
	score_labels[0].set_position(Vector2(LABEL_PADDING, 0.5*vp.y))
	score_labels[1].set_position(Vector2(vp.x - LABEL_PADDING, 0.5*vp.y))

func color_labels():
	for i in range(2):
		score_labels[i].modulate = GDict.cfg.colors.teams[i].lightened(0.5)

func save_perma_score(team_num, val):
	perma_scores[team_num] += val

func update_for(team_num : int, val : int):
	var real_val = perma_scores[team_num] + val
	var nothing_changed = real_val == scores[team_num]
	if nothing_changed: return
	
	scores[team_num] = real_val
	
	var label = score_labels[team_num]
	var new_val = str(real_val)

	label.get_node("Label").set_text(new_val)
	GTween.tween_label(score_labels[team_num])

	if val >= GDict.cfg.num_points_to_win:
		main_node.gameover.game_over(team_num)
