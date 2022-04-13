extends StaticBody2D

@onready var col_node = $CollisionPolygon2D

var team
@onready var drawer = $Drawer

const TIMER_BOUNDS : Dictionary = { 'min': 0.8, 'max': 2.2 }
const BLOW_AWAY_FORCE : float = 3000.0
const BALL_BLOW_AWAY_FORCE : float = 400.0
@onready var timer : Timer = $BlowAwayForce/Timer
@onready var area : Area2D = $BlowAwayForce/Area2D
@onready var anim_player : AnimationPlayer = $BlowAwayForce/AnimationPlayer

func _ready():
	restart_timer()

func set_team(t_num):
	team = t_num
	drawer.update()

func set_size(size : Vector2):
	drawer.update()

func restart_timer():
	timer.wait_time = randf_range(TIMER_BOUNDS.min, TIMER_BOUNDS.max)
	timer.start()

func blow_away_surroundings():
	var bodies = area.get_overlapping_bodies()
	var did_something : bool = false
	for b in bodies:
		if not (b.is_in_group("Players") or b.is_in_group("Balls")): continue

		var vec_away = (b.global_transform.origin - global_transform.origin).normalized()
		var force = BLOW_AWAY_FORCE
		if b.is_in_group("Balls"): force = BALL_BLOW_AWAY_FORCE
		
		did_something = true
		b.apply_central_impulse(vec_away * force)
	
	if did_something:
		play_blow_away_animation()

func play_blow_away_animation():
	anim_player.play("CircleGrow")

func _on_timer_timeout():
	restart_timer()
	blow_away_surroundings()
