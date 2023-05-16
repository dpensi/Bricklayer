extends Node

export(Vector2) var MapSize = Vector2(50,50)
export(int) var MapScale = 3
export(int) var RoadSize = 2
export(Vector2) var BuildingMinSize = Vector2(5, 5)
export(Vector2) var BuildingMaxSize = Vector2(15, 15)
export(int) var BuildingDistance = 3
export(int) var Seed = 0
export(bool) var RandomizeSeed = false

onready var city_map = get_node("CityMap")
onready var city = get_node("City")
onready var cell_size = city_map.cell_size

var rnd = RandomNumberGenerator.new()
var road_plans = []

enum RectTypes {
	RESIDENTIAL	= 0,
	COMMERCIAL	= 1,
	INDUSTRIAL	= 2,
	ROAD		= 3,
	INTERIOR	= 4,
	WALL		= 5
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
	generate_city_terrain()
	plan_roads()
	build_roads()
	build_buildings()

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
		var rnd_rect = get_random_rect(MapSize)
		put_rect(rnd_rect, rnd.randi_range(0, 2))
		used_cells_no = city_map.get_used_cells().size()

func get_random_rect(maximum):
	var corner1
	var corner2
	var start
	var end
	
	corner1 = get_random_point(0, maximum)
	corner2 = get_random_point(0, maximum)
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

func get_random_building():
	var rand_range_x = rnd.randi_range(
		BuildingMinSize.x, 
		BuildingMaxSize.x)
	var rand_range_y = rnd.randi_range(
		BuildingMinSize.y, 
		BuildingMaxSize.y)
	var size = Vector2(
		rand_range_x + BuildingDistance * 2,
		rand_range_y + BuildingDistance * 2
	)
	return Rect2(Vector2.ZERO, size)
		
	
func get_random_point(minimum, maximum):
	return Vector2(\
		rnd.randi_range(minimum, maximum.x),
		rnd.randi_range(minimum, maximum.y))
		
func put_rect(rect, floor_type, grid = city_map):
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			grid.set_cell(x, y, floor_type)

func generate_city_terrain():
	# create scaled terrain
	for x in range(MapSize.x):
		for y in range(MapSize.y):
			var tile_type = get_tile_type(city_map, x, y)
			create_block(Vector2(x, y), tile_type)

func get_tile_type(grid, x, y):
	var tile_id = grid.get_cell(x, y)
	var tile_type = int(\
		grid.tile_set.tile_get_name(tile_id))
	return tile_type

func create_block(
	up_left_corner, 
	tile_type):
		
	var city_x = up_left_corner.x * MapScale
	var city_y = up_left_corner.y * MapScale
	for x in range(city_x, city_x + MapScale):
		for y in range(city_y, city_y + MapScale):
			city.set_cell(x, y, tile_type)

func plan_roads():	
	for x in range(MapSize.x * MapScale):
		for y in range(MapSize.y * MapScale):
			var tile_type = get_tile_type(city, x, y)
			road_plans.append_array(get_road_plans(
				Vector2(x,y), tile_type
			))

func build_roads():
	for plan in road_plans:
		city.set_cell(
			plan.point_a.x, plan.point_a.y, RectTypes.ROAD)
		city.set_cell(
			plan.point_b.x, plan.point_b.y, RectTypes.ROAD)

# returns an array of RoadBlueprint calculated
# by checking the neighbours of `position`,
# a RoadBlueprint is added to the returned array
# if `position` has a neighbour of different type
func get_road_plans(position, tile_type):
	var neighbours = get_neighbours_type(city, position )
	var plans = []
	
	if neighbours.north != null \
		and neighbours.north != tile_type:
		
		var road_bp = RoadBlueprint.new()
		road_bp.point_a = position
		road_bp.point_b = Vector2(position.x, position.y - 1)
		road_bp.orientation = RoadOrientation.HORIZONTAL
		plans.append(road_bp)
		
	if neighbours.south != null \
		and neighbours.south != tile_type:
		
		var road_bp = RoadBlueprint.new()
		road_bp.point_a = position
		road_bp.point_b = Vector2(position.x, position.y + 1)
		road_bp.orientation = RoadOrientation.HORIZONTAL
		plans.append(road_bp)
		
	if neighbours.east != null \
		and neighbours.east != tile_type:
		
		var road_bp = RoadBlueprint.new()
		road_bp.point_a = position
		road_bp.point_b = Vector2(position.x + 1, position.y)
		road_bp.orientation = RoadOrientation.VERTICAL
		plans.append(road_bp)
		
	if neighbours.west != null \
		and neighbours.west != tile_type:
		var road_bp = RoadBlueprint.new()
		road_bp.point_a = position
		road_bp.point_b = Vector2(position.x - 1, position.y)
		road_bp.orientation = RoadOrientation.HORIZONTAL
		plans.append(road_bp)
		
	return plans

func build_buildings():
	# counts the loop where no building was inserted
	var void_loop = 0
	while void_loop < 10:
		# get random building
		var rand_rect = get_random_building()
		var building_inserted = false
		
		for x in range(MapSize.x * MapScale):
			for y in range(MapSize.y * MapScale):			
				#shift building for x and y position
				var shifted_rect = Rect2(rand_rect) 
				shifted_rect.position = Vector2(
					shifted_rect.position.x + x,
					shifted_rect.position.y + y
				)
				shifted_rect.end = Vector2(
					shifted_rect.end.x + x,
					shifted_rect.end.y + y
				)
				
				if is_homogeneus(shifted_rect):
					build_rect(shifted_rect)
					building_inserted = true
				
				
		if not building_inserted:
			void_loop += 1

func build_rect(rect):
	var start = Vector2(
		rect.position.x + BuildingDistance,
		rect.position.y + BuildingDistance
	)
	var size = Vector2(
		rect.size.x - BuildingDistance * 2,
		rect.size.y - BuildingDistance * 2
	)
	var walls = Rect2(start, size)
	put_rect(walls, RectTypes.WALL, city)
	print(rect)

# returns true if the Rect2 `rect` has the same tile
# in all his area, false otherwise
func is_homogeneus(rect):
	var type = city.get_cellv(rect.position)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if type != city.get_cell(x, y):
				return false
	return true

# return a NeighboursType object filled with the
# neighbours of the cell at `position`
func get_neighbours_type(grid, position):
	var x = position.x
	var y = position.y
	var neighbours = NeighboursTypes.new()
	
	if grid.get_cell(x, y-1) != grid.INVALID_CELL:
		neighbours.north = int(\
			grid.tile_set.tile_get_name(\
				grid.get_cell(x, y-1))) 
	if grid.get_cell(x, y+1) != grid.INVALID_CELL:
		neighbours.south = int(\
			grid.tile_set.tile_get_name(\
				grid.get_cell(x, y+1)))
	if grid.get_cell(x-1, y) != grid.INVALID_CELL:
		neighbours.west = int(\
			grid.tile_set.tile_get_name(\
				grid.get_cell(x-1, y)))
	if grid.get_cell(x+1, y) != grid.INVALID_CELL:
		neighbours.east = int(\
			grid.tile_set.tile_get_name(\
				grid.get_cell(x+1, y)))
	return neighbours

func from_map_to_city(coordinate):
	return coordinate * MapScale
func from_city_to_map(coordinate):
	return Vector2(\
		ceil(coordinate.x / MapScale),
		ceil(coordinate.y / MapScale))

class NeighboursTypes:
	var north
	var south
	var east
	var west

class RoadBlueprint:
	var point_a
	var point_b
	var orientation
