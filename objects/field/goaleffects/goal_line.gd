extends Line2D

var original_points : Array = []
var point_velocities : Array = []
var time : float = 0.0

var max_amplitude : float = 5.0
var wobble_speed : float = 5.0

func create(from : Vector2, num_steps : int, length : float):
	var step_size = length / num_steps
	var new_points : Array = [from]
	point_velocities = [0]
	for i in range(num_steps):
		from += step_size * Vector2.RIGHT
		new_points.append(from)
		point_velocities.append(0)
	
	original_points = new_points
	points = original_points

func apply_impulse_at_random_point(impulse_strength : float = 1.0):
	# exclude start and end point, they are fixed
	var rand_index = randi_range(1, original_points.size()-1)
	point_velocities[rand_index] += impulse_strength

func _physics_process(dt):
	var new_points = Array(points) + []
	var speed = 0.5
	for i in range(1, new_points.size() - 1):
		var dist_a = (points[i-1].y - points[i].y)
		var dist_b = (points[i+1].y - points[i].y)
		var dist_to_center = (original_points[i].y - points[i].y)
		
		point_velocities[i] *= 0.985 # slowly dampen it
		point_velocities[i] += speed*dt*dist_to_center # move it back to center
		point_velocities[i] += speed*dt*(dist_a + dist_b) # allow points around to pull on it
		new_points[i] += Vector2.DOWN * point_velocities[i]

	points = new_points

func _on_timer_timeout():
	apply_impulse_at_random_point()

func apply_impulse_at_closest_point(pos : Vector2, impulse_strength : float):
	var closest_point_index : int = -1
	var closest_dist : float = INF
	
	var dir = 1
	if pos.y < to_global(points[0]).y: dir = -1
	
	for i in range(points.size()):
		var p = points[i]
		var global_pos = to_global(p)
		var dist = (pos - global_pos).length()
		if dist >= closest_dist: continue
		
		closest_dist = dist
		closest_point_index = i
	
	point_velocities[closest_point_index] = dir * impulse_strength
