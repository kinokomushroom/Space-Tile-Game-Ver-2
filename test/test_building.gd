extends Node2D

const tile_list = ["base 1", "base 2", "base 3", "base 4", "base 5", "base 6", "base 7",
"cockpit 1", "cockpit 2", "cockpit 3", "engine 1", "engine 2", "engine 3", "engine 4",
"fuel 1", "fuel 2", "fuel 3"]
const grid = 16

var tile_scn = []
var buttons = []
var input_boxes_1 = []
var input_boxes_2 = []

var key_list = []
var action_list = []

var current_tile

var crr_tile_select = 0
var crr_tile_rotation = 0
var crr_tile_flip = Vector2(1, 1)
var place_tile = false
var change_tile = false

var button_state = []
var last_button_state = []
var mouse_state = false
var last_mouse_state = false
var mouse_enter = false

var test = false



func allign_to_grid():
	var tile_pos = get_global_mouse_position()
	tile_pos.x = tile_pos.x - (int(tile_pos.x) % grid)
	tile_pos.y = tile_pos.y - (int(tile_pos.y) % grid)
	return(tile_pos)

func new_tile(i):
	current_tile = tile_scn[i].instance()
	get_node("rigid bodies/ship 1").add_child(current_tile)

func is_button_pressed(i):
	if button_state[i] != last_button_state[i]:
		if button_state[i] == true:
			return(true)
		else:
			return(false)
	else:
		return(false)

func mouse_entered_button():
	mouse_enter = true

func mouse_exited_button():
	mouse_enter = false



func _ready():
	get_node("rigid bodies/ship 1").sleeping = true
	
	for i in tile_list.size():
		tile_scn.append(load("res://test/test tile scenes/" + tile_list[i] + ".tscn"))
	
	for i in get_node("Control").get_child_count() - 1:
		buttons.append(get_node("Control").get_child(i))
	for i in get_node("Control/inputs").get_child_count():
		input_boxes_1.append(get_node("Control/inputs").get_child(i).get_child(0))
	for i in get_node("Control/inputs").get_child_count():
		input_boxes_2.append(get_node("Control/inputs").get_child(i).get_child(1))
	
	for i in buttons.size():
		buttons[i].connect("mouse_entered", self, "mouse_entered_button")
		buttons[i].connect("mouse_exited", self, "mouse_exited_button")
	for i in input_boxes_1.size():
		input_boxes_1[i].connect("mouse_entered", self, "mouse_entered_button")
		input_boxes_1[i].connect("mouse_exited", self, "mouse_exited_button")
	for i in input_boxes_2.size():
		input_boxes_2[i].connect("mouse_entered", self, "mouse_entered_button")
		input_boxes_2[i].connect("mouse_exited", self, "mouse_exited_button")
	
	for i in buttons.size():
		button_state.append(buttons[i].pressed)
	last_button_state = button_state
	
	new_tile(0)
	
	set_process(true)



func _process(delta):
	key_list = []
	action_list = []
	for i in input_boxes_1.size():
		key_list.append(input_boxes_1[i].text)
		action_list.append(input_boxes_2[i].text.split_floats(",", false))
	
	
	place_tile = false
	if Input.is_mouse_button_pressed(1) == true:
		mouse_state = true
	else:
		mouse_state = false
	if mouse_state != last_mouse_state:
		if mouse_state == true:
			place_tile = true
	last_mouse_state = mouse_state
	
	button_state = []
	for i in buttons.size():
		button_state.append(buttons[i].pressed)
	change_tile = false
	if is_button_pressed(0) == true:
		change_tile = true
		crr_tile_select += 1
		if crr_tile_select >= tile_scn.size():
			crr_tile_select -= tile_scn.size()
	if is_button_pressed(1) == true:
		change_tile = true
		crr_tile_select -= 1
		if crr_tile_select < 0:
			crr_tile_select += tile_scn.size()
	if is_button_pressed(2) == true:
		crr_tile_rotation += 90
	if is_button_pressed(3) == true:
		crr_tile_rotation -= 90
	crr_tile_flip = current_tile.scale.rotated(deg2rad(crr_tile_rotation)) * Vector2(1, 1)
	if is_button_pressed(4) == true:
		crr_tile_flip = current_tile.scale.rotated(deg2rad(crr_tile_rotation)) * Vector2(1, -1)
	if is_button_pressed(5) == true:
		crr_tile_flip = current_tile.scale.rotated(deg2rad(crr_tile_rotation)) * Vector2(-1, 1)
	if is_button_pressed(6) == true:
		current_tile.queue_free()
		test = true
		for i in buttons.size():
			buttons[i].visible = false
		get_node("rigid bodies/ship 1").sleeping = false
		get_node("rigid bodies/ship 1").keys = key_list
		get_node("rigid bodies/ship 1").actions = action_list
	last_button_state = button_state
	
	if mouse_enter == true:
		place_tile = false
	
	
	if place_tile == true:
		new_tile(crr_tile_select)
	
	if change_tile == true:
		current_tile.queue_free()
		new_tile(crr_tile_select)
	
	
	current_tile.position = allign_to_grid()
	current_tile.rotation_degrees = crr_tile_rotation
	current_tile.scale = crr_tile_flip.rotated(deg2rad(-crr_tile_rotation))
	
	
	if test == true:
		set_process(false)

