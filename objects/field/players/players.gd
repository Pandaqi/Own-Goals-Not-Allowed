extends Node2D

@onready var field = get_parent()

var players : Array = []
var players_by_num : Dictionary = {}
var player_scene : PackedScene = preload("res://objects/player/player.tscn")

func activate():
	create_initial_players()

func create_initial_players():
	var num_players = field.main_node.num_players
	for i in range(num_players):
		players_by_num[str(i)] = []
	
	var first_field = field.main_node.field_manager.count() == 1
	if first_field:
		for i in range(num_players):
			add_player(i)
	
	else:
		var p0 = field.main_node.players.get_least_occuring_player_of_team(0)
		var p1 = field.main_node.players.get_least_occuring_player_of_team(1)
		add_player(p0)
		add_player(p1)

func add_player(p_num : int, desired_pos = null, powerup_data : Dictionary = {}):
	var p = player_scene.instantiate()
	
	if (desired_pos == null):
		p.set_position(field.get_random_position_inside())
	else:
		p.set_position(desired_pos)
	
	p.field = field
	p.busy_adding = true
	add_child(p)
	
	p.set_data(p_num, GDict.player_data[p_num].team)

	players.append(p)
	players_by_num[str(p_num)].append(p)
	
	play_add_tween(p)
	
	if powerup_data.has('type'):
		p.powerups.grab(powerup_data)

func remove_player(p_num : int):
	var node_to_remove = players_by_num[str(p_num)][0]
	remove_player_by_node(node_to_remove)

func remove_player_by_node(node):
	node.busy_removing = true
	
	var p_num = node.player_num
	players_by_num[str(p_num)].erase(node)
	players.erase(node)
	play_remove_tween(node)
	

func play_add_tween(node):
	node.set_scale(Vector2.ZERO)
	
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2(1.2, 0.8), 0.2)
	tw.tween_property(node, "scale", Vector2(0.9, 1.1), 0.2)
	tw.tween_property(node, "scale", Vector2.ONE, 0.1)
	tw.tween_callback(node.initialization_finished)

func play_remove_tween(node):
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2.ONE*1.2, 0.2)
	tw.tween_property(node, "scale", Vector2.ZERO, 0.2)
	tw.tween_callback(node.queue_free)

func give_input(p_num : int, vec : Vector2):
	for p in players_by_num[str(p_num)]:
		p.handle_input(vec)

func get_with_player_num(p_num : int) -> Array:
	return players_by_num[str(p_num)]

func count_instances_of(p_num : int) -> int:
	return players_by_num[str(p_num)].size()

func count_instances_of_team(t_num : int) -> int:
	var all_players_in_team = field.main_node.players.get_team(t_num)
	var sum : int = 0
	for p in all_players_in_team:
		sum += players_by_num[str(p)].size()
	return sum

func team_at_max_capacity(t_num : int) -> bool:
	return count_instances_of_team(t_num) >= get_max_capacity()

# TO DO: finetune this => not used ATM though
func get_max_capacity():
	return field.main_node.num_real_players + 2

func get_non_present_player_num_from_team(t_num : int) -> int:
	var all_players_in_team = field.main_node.players.get_team(t_num)
	for p in players:
		all_players_in_team.erase(p.player_num)
	
	if all_players_in_team.size() <= 0: return -1
	return all_players_in_team[randi() % all_players_in_team.size()]

func get_dist_to_closest(pos : Vector2) -> float:
	var closest_dist : float = INF
	
	for p in players:
		var dist = (p.position - pos).length()
		if dist >= closest_dist: continue
		closest_dist = dist
	
	return closest_dist

func remove_all(data : Dictionary):
	for i in range(players.size()-1,-1,-1):
		var p = players[i]
		if data.has('exclude'):
			if p in data.exclude: continue
		
		if data.has('team'):
			if p.team_num != data.team: continue
		
		remove_player_by_node(players[i])

func change_size_all(val : float):
	for p in players:
		p.shaper.change_size(val)
