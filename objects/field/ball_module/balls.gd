extends Node2D

@onready var field = get_parent()

const NUM_STARTING_BALLS : int = 1
var ball_scene : PackedScene = preload("res://objects/balls/ball.tscn")
var balls : Array = []

const STARTING_IMPULSE : float = 100.0

func activate():
	create_starting_balls()

func create_starting_balls():
	for i in range(NUM_STARTING_BALLS):
		create_ball()

func get_random_vector() -> Vector2:
	var ang = 2*randf()*PI
	return Vector2(cos(ang), sin(ang))

func create_ball():
	var b = ball_scene.instantiate()
	b.set_position(Vector2.ZERO)
	b.field = field
	balls.append(b)
	add_child(b)
	
	b.apply_central_impulse(STARTING_IMPULSE * get_random_vector())

func destroy_ball(node):
	balls.erase(node)
	node.queue_free()

func _physics_process(dt):
	check_for_goals()

func check_for_goals():
	var size = field.get_size()
	for b in balls:
		if b.is_teleporting(): continue
		if not b.is_scoreable(): continue
		
		var local_position = b.global_transform.origin - global_position
		if local_position.y > 0.5*size.y: scored_in_goal(field.bottom_team, b, false)
		elif local_position.y < -0.5*size.y: scored_in_goal(field.top_team, b, true)

func is_own_goal(team_num, ball) -> bool:
	return ball.get_last_touching_team_num() == team_num

# TO DO: make this a signal instead that is connected with all those other parts?
func scored_in_goal(team_num : int, ball, top_goal : bool):
	var own_goal = is_own_goal(team_num, ball)
	
	field.goaleffects.execute(ball, own_goal)
	field.score.scored_in_goal(team_num, ball)
	field.edges.scored_in_goal(top_goal, ball)
	ball.on_goal_scored()
	field.main_node.field_manager.scored_in_goal(team_num, ball, own_goal)
	
	destroy_ball(ball)
	
	if balls.size() <= 0: create_ball()

func get_dist_to_closest(pos : Vector2) -> float:
	var closest_dist : float = INF
	
	for b in balls:
		var dist = (b.position - pos).length()
		if dist >= closest_dist: continue
		closest_dist = dist
	
	return closest_dist

func change_type_to(tp : String):
	for b in balls:
		b.set_type(tp)
