extends Node2D

var interfaces : Array = []

func _ready():
	for child in get_children():
		interfaces.append(child)
	
	for i in range(interfaces.size()):
		var team_num = i % 2
		interfaces[i].set_player_num(i, team_num)
	
	login_existing_players()

func login_existing_players():
	for i in range(interfaces.size()):
		if i < GInput.get_player_count():
			interfaces[i].activate()
		else:
			interfaces[i].deactivate()

func _input(ev):
	var res = GInput.check_new_player(ev)
	if res.failed: return
	
	interfaces[res.num].activate()

func on_player_ready():
	var num = count_players_ready()
	var total_num = GInput.get_player_count()
	if num < total_num: return
	
	get_tree().change_scene("res://gameloop/main.tscn")

func count_players_ready() -> int:
	var sum : int = 0
	for i in interfaces:
		if not i.is_active: continue
		if not i.is_ready: continue
		sum += 1
	return sum

# TO DO: Leads to double activations, doesn't work in general
func on_player_removed(removed_interface):
	var my_index = interfaces.find(removed_interface)
	for i in range(my_index, interfaces.size()):
		var interface = interfaces[i]
		if i < GInput.get_player_count():
			interface.activate()
			
			if i < (interfaces.size() - 1):
				interfaces[i+1].deactivate()
