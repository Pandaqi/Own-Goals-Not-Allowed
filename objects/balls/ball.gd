extends RigidDynamicBody2D

const VEL_BOUNDS : Dictionary = { 'min': 50.0, 'max': 700.0 }
var last_touch = null
var last_touch_num : int = -1
var teleport_pos = null
var can_score : bool = true
var field

@onready var no_goal_timer : Timer = $NoGoalTimer
@onready var drawer : Node2D = $Drawer
@onready var sprite : Sprite2D = $Drawer/Sprite2D

var type : String = "regular"

const LINEAR_DAMPING : float = 0.3

func _ready():
	linear_damp = LINEAR_DAMPING
	GTween.tween_bounce(self)

func set_type(tp : String):
	type = tp
	sprite.set_frame(GDict.ball_types[type].frame)
	
	if type == 'extra_bouncy':
		physics_material_override = physics_material_override.duplicate(true)
		physics_material_override.bounce = 2.5
	
	elif type == 'not_bouncy':
		physics_material_override = physics_material_override.duplicate(true)
		physics_material_override.bounce = 0.0
		
		linear_damp = LINEAR_DAMPING * 5.0
	
	elif type == 'small':
		$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate(true)
		$CollisionShape2D.shape.radius *= 0.5
		sprite.scale *= 0.5
		drawer.outline_thickness *= 0.5
	
	drawer.update()

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
	var factor = field.powerups.get_slowdown_factor()
	if type == 'extra_bouncy': factor *= 2.0
	elif type == 'not_bouncy': factor *= 0.5
	
	var speed = state.linear_velocity.length()
	var dir = state.linear_velocity.normalized()
	var capped_speed = clamp(speed, VEL_BOUNDS.min * factor, VEL_BOUNDS.max * factor)
	var new_speed = dir * capped_speed
	state.linear_velocity = new_speed

func _on_ball_body_entered(body):
	GAudio.play_dynamic_sound(self, "ball_hit")
	
	if not body.is_in_group("Players"): return
	last_touch = body
	last_touch_num = body.team_num
	
	drawer.change_color(GDict.cfg.colors.teams[last_touch.team_num])

func reset_last_touch():
	last_touch = null
	drawer.reset_color()

func get_last_touching_player():
	if not is_instance_valid(last_touch): return null
	return last_touch

# NOTE: this is often the only thing we need
func get_last_touching_team_num() -> int:
	return last_touch_num

func on_goal_scored():
	reset_last_touch()
	can_score = false
	no_goal_timer.start()

func _on_no_goal_timer_timeout():
	can_score = true
