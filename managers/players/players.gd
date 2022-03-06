extends Node2D

@onready var main_node = get_parent()

var teams : Array = [
	[],
	[]
]

func activate():
	cache_team_members()

func cache_team_members():
	for i in range(GInput.get_player_count()):
		var data = GDict.player_data[i]
		teams[data.team].append(i)

func _physics_process(dt):
	poll_input()

func poll_input():
	var all_fields = main_node.field_manager.get_all_fields()
	
	for i in range(GInput.get_player_count()):
		var vec : Vector2 = GInput.get_move_vec(i)
		for f in all_fields:
			if f.busy_initializing: continue
			f.players.give_input(i, vec)

func count_instances_of(p_num : int) -> int:
	var all_fields = main_node.field_manager.get_all_fields()
	var sum : int = 0
	for f in all_fields:
		sum += f.players.count_instances_of(p_num)
	return sum

func get_team(t_num : int):
	return teams[t_num] + []

func get_random_player_num_in_team(t_num : int):
	var list = get_team(t_num)
	return list[randi() % list.size()]

func handle_players_without_character():
	if main_node.gameover.has_been_triggered(): return
	
	for i in range(GInput.get_player_count()):
		if count_instances_of(i) > 0: continue
		var f = main_node.field_manager.get_random_field()
		if f == null: continue
		f.add_player(i)
