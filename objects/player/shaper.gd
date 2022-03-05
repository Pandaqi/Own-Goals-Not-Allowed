extends Node2D

@onready var body = get_parent()

func activate():
	var original_shape = body.main_node.players.available_shapes[body.player_num]
	var shape = reposition_around_centroid(original_shape)
	
	var col_node = get_parent().get_node("CollisionPolygon2D")
	col_node.polygon = shape

	body.drawer.update_shape()

func reposition_around_centroid(shp, given_centroid = null):
	var centroid
	if given_centroid:
		centroid = given_centroid
	else:
		centroid = calculate_centroid(shp)
	
	for i in range(shp.size()):
		shp[i] -= centroid
	
	return shp

func calculate_centroid(shp):
	var avg = Vector2.ZERO
	for point in shp:
		avg += point
	
	return avg / float(shp.size())
