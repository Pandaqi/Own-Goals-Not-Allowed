extends Node2D

@onready var body = get_parent()
@onready var particles = $GPUParticles2D
var color : Color

var outline_thickness : float = 5.0

func _ready():
	reset_color()

func reset_color():
	change_color(GDict.cfg.colors.ball)

func change_color(col : Color):
	color = col
	particles.color = col.lightened(0.5)
	update()

func _draw():
	var radius = body.get_node("CollisionShape2D").shape.radius
	draw_circle(Vector2.ZERO, radius, color)
	
	if outline_thickness > 0:
		draw_arc(Vector2.ZERO, radius, 0, 2*PI, 20, color.darkened(0.5), outline_thickness, true)
