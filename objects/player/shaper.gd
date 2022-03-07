extends Node2D

@onready var body = get_parent()
var col_node

func activate():
	var original_shape = GDict.available_shapes[body.player_num]
	var shape = reposition_around_centroid(original_shape)
	
	col_node = get_parent().get_node("CollisionPolygon2D")
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

func shrink(val : float):
	var cur_shape = Array(col_node.polygon) + []
	var new_shape = GDict.scale_shape(cur_shape, val)
	new_shape = reposition_around_centroid(new_shape)
	col_node.polygon = new_shape
	body.drawer.update_shape()
