extends Node2D

@onready var main_node = get_parent()

var teams : Array = [
	[],
	[]
]

func activate():
	cache_team_members()

func cache_team_members():
	for i in range(main_node.num_players):
		var data = GDict.player_data[i]
		teams[data.team].append(i)
	
	print(teams)

func _physics_process(dt):
	poll_input()

func poll_input():
	var all_fields = main_node.field_manager.get_all_fields()
	
	for i in range(main_node.num_real_players):
		var vec : Vector2 = GInput.get_move_vec(i)
		for f in all_fields:
			if f.busy_initializing: continue
			f.players.give_input(i, vec)

func count_instances_of(p_num : int) -> int:
	var all_fields = main_node.field_manager.get_all_fields()
	var sum : int = 0
	for f in all_fields:
		if f.is_busy(): continue
		sum += f.players.count_instances_of(p_num)
	return sum

func get_team(t_num : int):
	return teams[t_num] + []

func get_random_player_num_in_team(t_num : int):
	var list = get_team(t_num)
	return list[randi() % list.size()]

func handle_players_without_character():
	if main_node.gameover.has_been_triggered(): return
	
	for i in range(main_node.num_players):
		if count_instances_of(i) > 0: continue
		var f = main_node.field_manager.get_random_field()
		if f == null: continue
		f.players.add_player(i)

func execute_powerup_for_all(p_num : int, node):
	var list : Array = get_all_players_with_num(p_num)
	
	for p in list:
		p.powerups.grab(node)

func get_all_players_with_num(p_num : int) -> Array:
	var players = get_tree().get_nodes_in_group("Players")
	var list : Array = []
	for p in players:
		if p.player_num != p_num: continue
		list.append(p)
	return list

func get_least_occuring_player_of_team(team_num : int) -> int:
	var lowest_sum : int = 200
	var lowest_player = -1
	
	print("CHECKERONI")
	print(teams[team_num])
	
	for p_num in teams[team_num]:
		var sum = count_instances_of(p_num)
		if sum >= lowest_sum: continue
		
		lowest_sum = sum
		lowest_player = p_num

	return lowest_player
