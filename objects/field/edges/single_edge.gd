extends StaticBody2D

@onready var col_node = $CollisionShape2D
var col_shape

var player_blocking : bool = false
var team
@onready var drawer = $Drawer

func _ready():
	col_shape = col_node.shape.duplicate(true)
	col_node.shape = col_shape

func set_team(t_num):
	team = t_num
	drawer.update()

func set_size(size : Vector2):
	col_shape.size = size
	drawer.update()

func make_player_blocking():
	player_blocking = true
	
	collision_layer = 2
	collision_mask = 0
