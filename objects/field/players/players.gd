extends Node2D

@onready var field = get_parent()

var players : Array = []
var players_by_num : Dictionary = {}
var player_scene : PackedScene = preload("res://objects/player/player.tscn")

func activate():
	create_initial_players()

func create_initial_players():
	for i in range(GInput.get_player_count()):
		players_by_num[str(i)] = []
		add_player(i)

func add_player(p_num : int):
	var p = player_scene.instantiate()
	p.set_position(field.get_random_position_inside())
	add_child(p)
	
	p.set_data(p_num, GDict.player_data[p_num].team)
	
	players.append(p)
	players_by_num[str(p_num)].append(p)
	
	play_add_tween(p)

func remove_player(p_num : int):
	var node_to_remove = players_by_num[str(p_num)].pop_back()
	players.erase(node_to_remove)
	
	play_remove_tween(node_to_remove)

func play_add_tween(node):
	node.set_scale(Vector2.ZERO)
	
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2(1.2, 0.8), 0.2)
	tw.tween_property(node, "scale", Vector2(0.9, 1.1), 0.2)
	tw.tween_property(node, "scale", Vector2.ONE, 0.1)

func play_remove_tween(node):
	var tw = get_tree().create_tween()
	tw.tween_property(node, "scale", Vector2.ONE*1.2, 0.2)
	tw.tween_property(node, "scale", Vector2.ZERO, 0.2)
	tw.tween_callback(func(): node.queue_free())

func give_input(p_num : int, vec : Vector2):
	for p in players_by_num[str(p_num)]:
		p.handle_input(vec)

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

# TO DO: finetune this
func get_max_capacity():
	return GInput.get_player_count() + 2

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
