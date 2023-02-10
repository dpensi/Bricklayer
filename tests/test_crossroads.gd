extends Node

func _ready():
	test_plus_crossroad()
	test_angle_crossroad()

func test_plus_crossroad():
	# init the city builder with test params
	var brick_layer = load("res://Bricklayer.tscn")\
		.instance()
	brick_layer.MapSize = Vector2(2, 2)
	brick_layer.MapScale = 2
	brick_layer.RoadSize = 2
	brick_layer.city_map = get_node("PlusCrossroad/Map")
	brick_layer.cell_size = brick_layer.city_map.cell_size
	brick_layer.city = brick_layer.get_node("City")
	brick_layer.generate_city_terrain()
	brick_layer.plan_roads()
	brick_layer.build_roads()
	
	var expected = get_node("PlusCrossroad/ExpectedCity")
	var actual = brick_layer.city
	assert(expected.get_used_rect() == actual.get_used_rect())
	for x in brick_layer.city.get_used_rect().size.x:
		for y in brick_layer.city.get_used_rect().size.y:
			assert(actual.get_cell(x,y) == expected.get_cell(x,y))
			
	brick_layer.city.visible = true
	brick_layer.remove_child(brick_layer.city)
	get_node("PlusCrossroad").add_child(brick_layer.city)
	
	brick_layer.queue_free()

func test_angle_crossroad():
	push_error("not implemented yet")
	 

