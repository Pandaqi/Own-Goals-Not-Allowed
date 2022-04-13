extends Node2D

@onready var main_node = get_parent()

const BOT_TEAM : int = 1
var bot_player_nums : Array = []
var bot_data : Array = []
var bot_states : Array = [
	"normal", "normal", "normal", "normal",
	"pause", 
	"back_to_net", 
	"find_teleporter"]
var all_fields

func activate():
	if not GDict.cfg.bots: return
	
	var num_real_players = GInput.get_player_count()
	var total_players = clamp(num_real_players * 2, 2, 8)
	var bots = total_players - num_real_players
	
	# Cheap trick to make sure "bot_num" refers to the correct index
	# in bot_data Array later
	for i in range(num_real_players):
		bot_data.append({})
	
	for i in range(bots):
		var bot_player_num = num_real_players + i
		bot_player_nums.append(bot_player_num)
		bot_data.append({
			'state': 'normal',
			'switch_time': -1,
			'rand_offset': Vector2.ZERO
		})
	
	for i in range(total_players):
		if i < num_real_players:
			GDict.player_data[i].team = (BOT_TEAM + 1) % 2
		else:
			GDict.player_data[i].team = BOT_TEAM

func count() -> int:
	return bot_player_nums.size()

func _physics_process(dt):
	determine_input_for_all_bots()

func determine_input_for_all_bots():
	all_fields = main_node.field_manager.get_all_fields()
	
	for bot_num in bot_player_nums:
		var vec : Vector2 = determine_input_for_bot(bot_num)
		give_input_to_all_fields(bot_num, vec)

func give_input_to_all_fields(bot_num : int, vec : Vector2):
	for f in all_fields:
		if f.busy_initializing: continue
		f.players.give_input(bot_num, vec)

func determine_new_bot_state() -> String:
	return bot_states[randi() % bot_states.size()]

func determine_input_for_bot(bot_num : int) -> Vector2:
	
	var data = bot_data[bot_num]
	if data.switch_time < Time.get_ticks_msec():
		data.state = determine_new_bot_state()
		data.switch_time = Time.get_ticks_msec() + randf_range(1.0, 2.5)*1000.0
		data.rand_offset = Vector2(randf()-0.5, randf()-0.5).normalized()*40
	
	if data.state == 'pause': return Vector2.ZERO
	
	var field_data = []
	
	for f in all_fields:
		var b = f.balls.get_first()
		if b == null: continue
		
		var goal_pos = Vector2(0, -0.5*f.get_height())
		if f.bottom_team == BOT_TEAM:
			goal_pos.y = 0.5*f.get_height()
		
		var ball_vec_to_goal = (goal_pos - b.position).normalized()
		var ball_in_our_half = ( sign(b.position.y) == sign(goal_pos.y) )

		var closest_dist : float = 5000.0
		var closest_player = null
		var vec_to_wanted : Vector2 = Vector2.ZERO
		var player_list = f.players.get_with_player_num(bot_num)
		if player_list.size() <= 0: continue
		
		for p in player_list:
			var wanted_pos = b.position
			var vec_to_ball = (b.position - p.position).normalized()
			var vec_to_goal = (goal_pos - p.position).normalized()
			
			# moving into the ball now would shoot it in our goal?
			# move to its side then!
			if vec_to_goal.dot(vec_to_ball) > 0.4: 
				var side_dir = Vector2.RIGHT
				if p.position.x < b.position.x: side_dir = Vector2.LEFT
				side_dir = side_dir.rotated(randf_range(-0.2, 0.2)*PI)
				wanted_pos = b.position + side_dir*randf_range(100, 140)
			
			if data.state == 'back_to_net':
				wanted_pos = goal_pos + data.rand_offset
			elif data.state == 'find_teleporter':
				var teleport_num = bot_num % 2
				wanted_pos = f.gates.get_gate(teleport_num).position
			
			var dist = (p.position - wanted_pos).length()
			if dist >= closest_dist: continue
			
			closest_dist = dist
			closest_player = p
			vec_to_wanted = (wanted_pos - p.position).normalized()

		field_data.append({
			'vec': vec_to_wanted,
			'dist': closest_dist
		})
	
	var best_value = null
	var best_dist : float = 10000.0
	
	var final_vec : Vector2 = Vector2.ZERO
	var total_weight : float = 0.0
	for d in field_data:
		var weight = clamp(d.dist / 500.0, 0.03, 1.0) # closer gets higher weight
		final_vec += d.vec * weight
		total_weight += weight
		
		if d.dist >= best_dist: continue
		best_dist = d.dist
		best_value = d
	
	final_vec /= total_weight
	
	if best_value != null:
		if data.state == 'back_to_net' or data.state == 'find_teleporter':
			final_vec = best_value.vec
	
	return final_vec
