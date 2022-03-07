extends StaticBody2D

@onready var col_node = $CollisionPolygon2D

var team
@onready var drawer = $Drawer

func set_team(t_num):
	team = t_num
	drawer.update()

func set_size(size : Vector2):
	drawer.update()
	
	# TO DO: some functionality for resizing our shape on the fly
