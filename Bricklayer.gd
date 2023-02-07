extends Node

export(Vector2) var MapSize = Vector2(50,50)
export(int) var MapScale = 3
export(int) var RoadSize = 2
export(int) var Seed = 0
export(bool) var RandomizeSeed = false

onready var city_map = get_node("CityMap")
onready var city = get_node("City")
onready var cell_size = city_map.cell_size
onready var rnd = RandomNumberGenerator.new()

enum RectTypes {
  RESIDENTIAL	= 0,
  COMMERCIAL	= 1,
  INDUSTRIAL	= 2,
  ROAD			= 3
}

enum RoadOrientation {
	HORIZONTAL = 0,
	VERTICAL = 1
}

func _ready():
	
	if RandomizeSeed:
		rnd.randomize()
	else:
		rnd.seed = Seed
		
	if not checkInput():
		push_error("Input invalid, exiting")
		get_tree().quit()
		
	generate_map()
	generate_city()

func checkInput():
	var valid_input = true
	
	if MapSize.x < 12 or MapSize.y < 12:
		push_error("Map Size must be > 12")
		valid_input = false
	if RoadSize < 2 or RoadSize % 2 != 0:
		push_error("Road Size must be >= 2 and an even number")
		valid_input = false
	if MapScale < 3:
		push_error("Map Scale must be >= 3")
		valid_input = false
	return valid_input
	
func generate_map():
	var used_cells_no = city_map.get_used_cells().size()
	var total_cells = MapSize.x * MapSize.y
	while used_cells_no != total_cells:
		var rnd_rect = get_random_rect()
		put_rect(rnd_rect, rnd.randi_range(0, 2))
		used_cells_no = city_map.get_used_cells().size()

func get_random_rect():
	var corner1
	var corner2
	var start
	var end
	
	corner1 = get_random_point()
	corner2 = get_random_point()
	if corner1 < corner2:
		start = corner1
		end = corner2
	else:
		start = corner2
		end = corner1
		
	var rect = Rect2(		\
		start.x, start.y, 	\
		end.x - start.x,	\
		end.y - start.y)
	
	return rect.abs()
	
func get_random_point():
	return Vector2(\
		rnd.randi_range(0, MapSize.x),
		rnd.randi_range(0, MapSize.y))
		
func put_rect(rect, floor_type):
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			city_map.set_cell(x, y, floor_type)

func generate_city():
	# create scaled terrain
	for x in range(MapSize.x):
		for y in range(MapSize.y):
			var tile_type = get_tile_type(city_map, x, y)
			create_block(x, y, tile_type)
	
	#create roads
#	for x in range(MapSize.x * MapScale):
#		for y in range(MapSize.y * MapScale):
#			var tile_type = get_tile_type(city, x, y)
#			var nsew = get_neighbours_type(city, x, y)
#			for neighbour_type in nsew:
#				if tile_type != neighbour_type:
#					city.set_cell(\
#						x, y, RectTypes.ROAD)
			
func get_tile_type(grid, x, y):
	var tile_id = grid.get_cell(x, y)
	var tile_type = int(\
		grid.tile_set.tile_get_name(tile_id))
	return tile_type

func create_block(
	map_x, 
	map_y, 
	tile_type):
		
	var city_x = map_x * MapScale
	var city_y = map_y * MapScale
	for x in range(city_x, city_x + MapScale):
		for y in range(city_y, city_y + MapScale):
			city.set_cell(x, y, tile_type)

func get_neighbours_type(grid, x, y):
	var nsew = []
	nsew.append(int(\
		grid.tile_set.tile_get_name(\
			grid.get_cell(x, y-1)))) #north
	nsew.append( int(\
		grid.tile_set.tile_get_name(\
			grid.get_cell(x, y+1)))) #south
	nsew.append(int(\
		grid.tile_set.tile_get_name(\
			grid.get_cell(x-1, y)))) #east
	nsew.append(int(\
		grid.tile_set.tile_get_name(\
			grid.get_cell(x+1, y)))) #west
	return nsew
	
func from_map_to_city(coordinate):
	return coordinate * MapScale
func from_city_to_map(coordinate):
	return Vector2(\
		ceil(coordinate.x / MapScale),
		ceil(coordinate.y / MapScale))
