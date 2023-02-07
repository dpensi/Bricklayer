extends Camera2D

export(float) var Speed = 30
export(float) var ZoomSpeed = 0.2
export(float) var ZoomStep = 0.5

onready var city_map = get_parent().get_node("CityMap")
onready var city = get_parent().get_node("City")

var direction 
var wheel_up
var wheel_down

func _process(_delta):
	direction = Input.get_vector(
		"ui_left","ui_right", "ui_up", "ui_down")
	
	wheel_up = Input.is_action_just_released("ui_zoom_in")
	wheel_down = Input.is_action_just_released("ui_zoom_out")
	
	if  wheel_down: # zoom in 
		zoom.x = lerp(zoom.x, zoom.x - ZoomStep, ZoomSpeed)
		zoom.y = lerp(zoom.y, zoom.y - ZoomStep, ZoomSpeed)
	if wheel_up: # zoom out
		zoom.x = lerp(zoom.x, zoom.x + ZoomStep, ZoomSpeed)
		zoom.y = lerp(zoom.y, zoom.y + ZoomStep, ZoomSpeed)
	zoom.x = clamp(zoom.x, 0.5, 10)
	zoom.y = clamp(zoom.y, 0.5, 10)
	position += direction * Speed
	
	if Input.is_action_just_pressed("ui_click"):
		city.visible = not city.visible
		city_map.visible = not city_map.visible 
