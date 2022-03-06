extends Node2D

@onready var field = get_parent()

const OWN_GOAL_BONUS : int = 10

# percentage of total size
const LABEL_OFFSET_FROM_GOAL : float = 0.1
const LABEL_ALPHA : float = 0.25

var score : Array = [0,0]
@onready var score_labels : Array = [
	$ScoreLabel0,
	$ScoreLabel1
]

func get_score(t_num : int):
	return score[t_num]

func update_from_field():
	var size = field.get_size()
	score_labels[0].set_position(Vector2(0, LABEL_OFFSET_FROM_GOAL*size.y - 0.5*size.y))
	score_labels[1].set_position(Vector2(0, (1.0 - LABEL_OFFSET_FROM_GOAL)*size.y - 0.5*size.y))
	
	score_labels[0].modulate = GDict.cfg.colors.teams[field.top_team]
	score_labels[0].modulate.a = LABEL_ALPHA
	
	score_labels[1].modulate = GDict.cfg.colors.teams[field.bottom_team]
	score_labels[1].modulate.a = LABEL_ALPHA

func get_for(team_num : int):
	return score[team_num]

func give_points_to(team_num : int, dp : int):
	score[team_num] += dp
	score_labels[team_num].set_value(score[team_num])
	field.field_manager.update_global_scores()

func is_own_goal(team_num, ball) -> bool:
	return ball.get_last_touching_team_num() == team_num

func scored_in_goal(team_num : int, ball):
	var other_team = (team_num + 1) % 2
	if is_own_goal(team_num, ball):
		give_points_to(other_team, OWN_GOAL_BONUS)
		return
	
	# RULE #1: The scoring player is removed here, as long as it's not their last one
	var scoring_player = ball.get_last_touching_player()
	if scoring_player != null:
		var player_num = scoring_player.player_num
		if field.main_node.players.count_instances_of(player_num) > 1 and field.players.count_instances_of_team(other_team) > 1:
			field.players.remove_player(player_num)
	
	# RULE #2: The losing team gets an extra player here, if it's missing (at least) one
	var new_player_num = field.players.get_non_present_player_num_from_team(team_num)
#	if new_player_num < 0 and not field.players.team_at_max_capacity(team_num):
#		new_player_num = field.main_node.players.get_random_player_num_in_team(team_num)
	
	if new_player_num >= 0: field.players.add_player(new_player_num)

	give_points_to(other_team, 1)
