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
	balls.append(b)
	add_child(b)
	
	b.apply_central_impulse(STARTING_IMPULSE * get_random_vector())

func _physics_process(dt):
	check_for_goals()

func check_for_goals():
	var size = field.get_size()
	for b in balls:
		if b.is_teleporting(): continue
		if not b.is_scoreable(): continue
		
		var local_position = b.global_transform.origin - global_position
		if local_position.y > 0.5*size.y: scored_in_goal(field.bottom_team,b)
		elif local_position.y < -0.5*size.y: scored_in_goal(field.top_team, b)

func scored_in_goal(team_num : int, ball):
	field.score.scored_in_goal(team_num, ball)
	ball.on_goal_scored()
	ball.plan_teleport(global_position + Vector2.ZERO)
