extends Node2D

var slowdown_factor : float = 1.0
@onready var field = get_parent()

func get_slowdown_factor() -> float:
	return slowdown_factor

func grab(powerup, grabber):
	var type = powerup.type
	
	if type == 'remove_all':
		field.players.remove_all({ 'exclude': [grabber] })
		field.main_node.players.handle_players_without_character()
	
	elif type == 'remove_opponents':
		var other_team = (grabber.team_num + 1) % 2
		field.players.remove_all({ 'team': other_team })
		field.main_node.players.handle_players_without_character()
	
	elif type == 'add_ball':
		field.balls.call_deferred("create_ball") # physics functions need to be deferred, as powerups are grabbed _during_ physics simulation
	
	elif type == 'ball_five':
		field.balls.change_type_to('five')
	
	elif type == 'ball_double':
		field.balls.change_type_to('double')
	
	elif type == 'full_slowdown':
		slowdown_factor = 0.2
	
	elif type == 'shrink_goals':
		field.edges.call_deferred("shrink_goals")
	
	elif type == 'grow_goals':
		field.edges.call_deferred("grow_goals")
	
	elif type == 'reverse_goal_dir':
		field.call_deferred("reverse_goal_dir")
