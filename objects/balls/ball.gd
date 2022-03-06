extends RigidDynamicBody2D

const VEL_BOUNDS : Dictionary = { 'min': 30.0, 'max': 500.0 }
var last_touch = null
var teleport_pos = null
var can_score : bool = true

@onready var no_goal_timer : Timer = $NoGoalTimer
@onready var drawer = $Drawer


func _ready():
	GTween.tween_bounce(self)

func plan_teleport(pos : Vector2):
	teleport_pos = pos

func is_teleporting() -> bool:
	return teleport_pos != null

func is_scoreable() -> bool:
	return can_score

func _integrate_forces(state):
	if is_teleporting():
		state.transform.origin = teleport_pos
		state.linear_velocity *= -0.1
		state.angular_velocity *= -0.1
		teleport_pos = null
		return
	
	cap_velocity(state)

func cap_velocity(state):
	var speed = state.linear_velocity.length()
	var dir = state.linear_velocity.normalized()
	var capped_speed = clamp(speed, VEL_BOUNDS.min, VEL_BOUNDS.max)
	var new_speed = dir * capped_speed
	state.linear_velocity = new_speed

func _on_ball_body_entered(body):
	if not body.is_in_group("Players"): return
	last_touch = body
	
	drawer.change_color(GDict.cfg.colors.teams[last_touch.team_num])

func reset_last_touch():
	last_touch = null
	drawer.reset_color()

func get_last_touching_player():
	if not is_instance_valid(last_touch): return null
	return last_touch

# NOTE: this is often the only thing we need
func get_last_touching_team_num():
	if last_touch == null: return -1
	return last_touch.team_num

func on_goal_scored():
	GTween.tween_bounce(self)
	reset_last_touch()
	can_score = false
	no_goal_timer.start()

func _on_no_goal_timer_timeout():
	can_score = true
