extends Node2D

@onready var body = get_parent()
var color : Color = Color(1.0, 0.0, 0.0)

var points : Array
var outline : Array
var outline_thickness = 0

func calculate_shape_list():
	var shape_list = []
	
	var num_shapes = body.shape_owner_get_shape_count(0)
	for i in range(num_shapes):
		var shape = body.shape_owner_get_shape(0, i)
		shape_list.append(shape.points)
	
	return shape_list

func update_shape():
	var shape_list = calculate_shape_list()

	# pre-inflate all shapes (to ensure merges work)
	for i in range(shape_list.size()):
		shape_list[i] = Geometry2D.offset_polygon(shape_list[i], 1.0)[0]
	
	# now keep merging with shapes until none left
	var counter = 1
	var full_polygon = shape_list[0]
	while shape_list.size() > 1 and counter < shape_list.size():
		var new_polygon = Geometry2D.merge_polygons(full_polygon, shape_list[counter])
		
		# no succesful merge? continue
		if new_polygon.size() > 1:
			counter += 1
			continue
		
		# succes? save the merged polygon, remove the other from the list and start searching again
		full_polygon = new_polygon[0]
		shape_list.remove_at(counter)
		counter = 1
	
	points = full_polygon
	
	var outline_margin = 0
	var outline_polygon = Geometry2D.offset_polygon(full_polygon, outline_margin)[0]
	outline_polygon.append(outline_polygon[0]) # add starting point at the end as well, to close the polygon

	outline = outline_polygon
	
	# finally, actually re-do the _draw() call
	update()

func _draw():
	color = GDict.cfg.colors.teams[body.team_num]
	
	draw_polygon(points, [color])
	
	if outline_thickness > 0:
		var outline_color = color.darkened(0.6)
		draw_polyline(outline, outline_color, outline_thickness, true)
