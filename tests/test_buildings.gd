extends Node


func _ready():
	test_homogeneus()
	test_non_homogeneus()
	test_walls()

func test_homogeneus():
	var brick_layer = load("res://Bricklayer.tscn")\
		.instance()
	brick_layer.city = get_node("IsHomogeneus/Homogeneus")
	
	var rect = Rect2(Vector2(0,0), Vector2(4,4))
	assert(brick_layer.is_homogeneus(rect))
	print("test_homogeneus passed") 
	
	brick_layer.queue_free()
	
func test_non_homogeneus():
	var brick_layer = load("res://Bricklayer.tscn")\
		.instance()
	brick_layer.city = get_node("IsHomogeneus/NonHomogeneus")
	
	var rect = Rect2(Vector2(0,0), Vector2(4,4))
	assert(not brick_layer.is_homogeneus(rect))
	print("test_non_homogeneus passed") 
	
	brick_layer.queue_free()
	
func test_walls():
	var brick_layer = load("res://Bricklayer.tscn")\
		.instance()
	brick_layer.city = get_node("Walls/City")
	brick_layer.MapSize = Vector2(5, 5)
	brick_layer.MapScale = 1
	brick_layer.BuildingMinSize = Vector2(3, 3)
	brick_layer.BuildingMaxSize = Vector2(3, 3)
	brick_layer.BuildingDistance = 1
	brick_layer.build_buildings()
