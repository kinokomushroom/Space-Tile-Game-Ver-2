extends Node2D

const tile_list = ["base 1", "base 2", "base 3", "base 4", "base 5", "base 6", "base 7", "base 8",
"cockpit 1", "cockpit 2", "cockpit 3", "engine 1", "engine 2", "engine 3", "engine 4",
"fuel 1", "fuel 2", "fuel 3", "laser 1", "laser 2"]
var tile_scn = []
var buttons = []

const grid = 16

var current_tile
var tile_num = 0
var edit_tile_list = []
var button_list = []

var crr_tile_type
var crr_tile_rotation = 0
var crr_tile_flip = Vector2(1, 1)
var place_tile = false
var change_tile = false
var dont_place_tile = false

var mode = "pen"
var last_mode = "pen"

var mouse_clicked = false
var last_mouse_clicked = false
var mouse_event = false

var selected_tile = null

const mode_select_pos = Vector2(8, 8)
const tile_select_pos = Vector2(224, 64)
const tile_controls_pos = Vector2(-144, -144)
const start_engine_pos = Vector2(-72, -64)
const save_pos = Vector2(-120, -56)
const load_pos = Vector2(80, -56)

var crr_color = Color(1.0, 1.0, 1.0)

var screen_size
var last_screen_size


func set_control_pos():
	screen_size = get_viewport().size
	if screen_size != last_screen_size:
		get_node("Control/mode select").rect_position = mode_select_pos
		get_node("Control/tile select").rect_position = tile_select_pos
		get_node("Control/tile controls").rect_position = screen_size + tile_controls_pos
		get_node("Control/start engine").rect_position = Vector2(screen_size.x/2 + start_engine_pos.x, screen_size.y + start_engine_pos.y)
		get_node("Control/save").rect_position = Vector2(screen_size.x/2 + save_pos.x, screen_size.y + save_pos.y)
		get_node("Control/load").rect_position = Vector2(screen_size.x/2 + load_pos.x, screen_size.y + load_pos.y)
	last_screen_size = screen_size

func allign_to_grid():
	var tile_pos = get_global_mouse_position()
	tile_pos.x = tile_pos.x - (int(tile_pos.x) % grid)
	tile_pos.y = tile_pos.y - (int(tile_pos.y) % grid)
	return(tile_pos)

func mouse_entered_tile(object):
	selected_tile = object
	object.get_child(0).get_child(0).modulate = Color(2.0, 2.0, 2.0)

func mouse_exited_tile(object):
	if selected_tile == object:
		selected_tile = null
	object.get_child(0).get_child(0).modulate = Color(1.0, 1.0, 1.0)
	
	if mode == "engine":
		if object.get_child(0).type == "Engine" or (object.get_child(0).type == "Laser" and object.get_child(0).property_1 == 1):
			object.get_child(0).get_child(2).visible = false

func mouse_new_tile(name):
	if mode == "pen":
		if current_tile != null:
			current_tile.queue_free()
		current_tile = tile_scn[tile_list.find(name)].instance()
		get_node("temporary/mouse").add_child(current_tile)
		
		if current_tile.type == "Base":
			get_node("Control/tile controls/color").visible = true
			get_node("Control/tile controls/color").color = crr_color
		else:
			get_node("Control/tile controls/color").visible = false

func canvas_new_tile(name):
	var new_tile = tile_scn[tile_list.find(name)].instance()
	
	var new_area = Area2D.new()
	get_node("temporary/canvas").add_child(new_area)
	new_area.add_child(new_tile)
	new_area.connect("mouse_entered", self, "mouse_entered_tile", [new_area])
	new_area.connect("mouse_exited", self, "mouse_exited_tile", [new_area])
	new_area.position = current_tile.position
	new_area.rotation = crr_tile_rotation
	new_area.scale = crr_tile_flip
	if new_tile.type == "Base":
		new_tile.modulate = crr_color
	
	new_tile.tile_num = tile_num
	tile_num += 1
	
	if new_tile.type == "Engine" or (new_tile.type == "Laser" and new_tile.property_1 == 1):
		var typebox = load("res://test/key typebox.tscn").instance()
		new_tile.add_child(typebox)
		typebox.rect_position = new_tile.com
		typebox.visible = false
	
	for i in new_tile.get_node("raycast").get_child_count():
		var ray = new_tile.get_node("raycast").get_child(i)
		ray.add_exception(new_area)
		for i in button_list.size():
			ray.add_exception(button_list[i])
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider().get_child(0)
			if new_tile.connected_tiles.find(collider) == -1:
				new_tile.connected_tiles.append(collider)
				if collider.connected_tiles.find(new_area.get_child(0)) == -1:
					collider.connected_tiles.append(new_area.get_child(0))
	
	for i in new_tile.get_node("raycast").get_child_count():
		var ray = new_tile.get_node("raycast").get_child(0)
		#new_tile.get_node("raycast").remove_child(ray)
		ray.queue_free()

func mode_button_pressed(object):
	mode = object.get_name()

func tile_button_pressed(object):
	crr_tile_type = object.get_name()
	change_tile = true

func control_button_pressed(object):
	if object.get_name() == "reset":
		crr_tile_rotation = 0
		crr_tile_flip = Vector2(1,1)
	if object.get_name() == "rotate right":
		crr_tile_rotation += PI/2
	if object.get_name() == "rotate left":
		crr_tile_rotation -= PI/2
	if object.get_name() == "flip horizontal":
		crr_tile_flip = (current_tile.scale.rotated(crr_tile_rotation) * Vector2(-1, 1)).rotated(-crr_tile_rotation)
	if object.get_name() == "flip vertical":
		crr_tile_flip = (current_tile.scale.rotated(crr_tile_rotation) * Vector2(1, -1)).rotated(-crr_tile_rotation)

func color_changed(color):
	crr_color = color
	current_tile.modulate = crr_color

func save_pressed():
	get_node("Control/FileDialog").popup()
	get_node("Control/FileDialog").mode = FileDialog.MODE_SAVE_FILE

func load_pressed():
	get_node("Control/FileDialog").popup()
	get_node("Control/FileDialog").mode = FileDialog.MODE_OPEN_FILE

func file_selected(path):
	if get_node("Control/FileDialog").mode == FileDialog.MODE_SAVE_FILE:
		var save = File.new()
		save.open(path, File.WRITE)
		
		for i in get_node("temporary/canvas").get_child_count():
			var area = get_node("temporary/canvas").get_child(i)
			var tile = area.get_child(0)
			var save_dict
			
			var connected_tiles_num = []
			for i in tile.connected_tiles.size():
				connected_tiles_num.append(tile.connected_tiles[i].tile_num)
			
			if tile.type == "Engine" or (tile.type == "Laser" and tile.property_1 == 1):
				save_dict = {
					"tile_name" : tile.tile_name,
					"tile_pos_x" : area.position.x,
					"tile_pos_y" : area.position.y,
					"tile_rot" : area.rotation,
					"tile_scale_x" : area.scale.x,
					"tile_scale_y" : area.scale.y,
					"tile_num" : tile.tile_num,
					"connected_tiles" : connected_tiles_num,
					"is_engine_or_laser" : true,
					"keys" : tile.get_child(2).get_child(0).text,
					"color_r" : tile.modulate.r,
					"color_g" : tile.modulate.g,
					"color_b" : tile.modulate.b
				}
			else:
				save_dict = {
					"tile_name" : tile.tile_name,
					"tile_pos_x" : area.position.x,
					"tile_pos_y" : area.position.y,
					"tile_rot" : area.rotation,
					"tile_scale_x" : area.scale.x,
					"tile_scale_y" : area.scale.y,
					"tile_num" : tile.tile_num,
					"connected_tiles" : connected_tiles_num,
					"is_engine_or_laser" : false,
					"keys" : null,
					"color_r" : tile.modulate.r,
					"color_g" : tile.modulate.g,
					"color_b" : tile.modulate.b
				}
			
			save.store_line(to_json(save_dict))
		
		save.close()

	if get_node("Control/FileDialog").mode == FileDialog.MODE_OPEN_FILE:
		for i in get_node("temporary/canvas").get_child_count():
			var area = get_node("temporary/canvas").get_child(0)
			get_node("temporary/canvas").remove_child(area)
			area.queue_free()
		
		var save = File.new()
		save.open(path, File.READ)
		while not save.eof_reached():
			var current_line = parse_json(save.get_line())
			if current_line != null:
				var new_tile = tile_scn[tile_list.find(current_line["tile_name"])].instance()
				var new_area = Area2D.new()
				get_node("temporary/canvas").add_child(new_area)
				new_area.add_child(new_tile)
				new_area.connect("mouse_entered", self, "mouse_entered_tile", [new_area])
				new_area.connect("mouse_exited", self, "mouse_exited_tile", [new_area])
				new_area.position = Vector2(current_line["tile_pos_x"], current_line["tile_pos_y"])
				new_area.rotation = current_line["tile_rot"]
				new_area.scale = Vector2(current_line["tile_scale_x"], current_line["tile_scale_y"])
				new_tile.tile_num = current_line["tile_num"]
				new_tile.connected_tiles = current_line["connected_tiles"]
				new_tile.modulate = Color(current_line["color_r"], current_line["color_g"], current_line["color_b"])
				
				if current_line["is_engine_or_laser"] == true:
					var typebox = load("res://test/key typebox.tscn").instance()
					new_tile.add_child(typebox)
					typebox.rect_position = new_tile.com
					typebox.visible = false
					typebox.get_child(0).text = current_line["keys"]
				
				for i in new_tile.get_node("raycast").get_child_count():
					var ray = new_tile.get_node("raycast").get_child(0)
					#new_tile.get_node("raycast").remove_child(ray)
					ray.queue_free()
		
		var temp_tile_arr = []
		var temp_num_arr = []
		for i in get_node("temporary/canvas").get_child_count():
			var tile = get_node("temporary/canvas").get_child(i).get_child(0)
			temp_tile_arr.append(tile)
			temp_num_arr.append(tile.tile_num)
		for i in get_node("temporary/canvas").get_child_count():
			var tile = get_node("temporary/canvas").get_child(i).get_child(0)
			for j in tile.connected_tiles.size():
				tile.connected_tiles[j] = temp_tile_arr[temp_num_arr.find(tile.connected_tiles[j])]
		
		save.close()

func color_shown():
	mode = "color"

func color_hidden():
	mode = "pen"

func popup_shown():
	mode = "popup"

func popup_hidden():
	mode = "pen"

func start_engine_pressed():
	if mode != "run":
		mode = "run"
		
		for i in get_node("Control").get_child_count():
			if get_node("Control").get_child(i).name != "start engine":
				get_node("Control").get_child(i).visible = false
		
		var body_count = 1
		var body_number_list = []
		for i in get_node("temporary/canvas").get_child_count():
			var tile = get_node("temporary/canvas").get_child(i).get_child(0)
			tile.body_number = 0
			if tile.type == "Engine" or (tile.type == "Laser" and tile.property_1 == 1):
				tile.get_child(2).visible = false
		
		for i in get_node("temporary/canvas").get_child_count():
			var tile = get_node("temporary/canvas").get_child(i).get_child(0)
			if tile.body_number == 0:
				tile.body_number = body_count
				body_number_list.append([tile])
				body_count += 1
			for i in tile.connected_tiles.size():
				var connected_tile = tile.connected_tiles[i]
				if connected_tile.body_number == 0:
					connected_tile.body_number = tile.body_number
					body_number_list[tile.body_number - 1].append(connected_tile)
				else:
					var connected_body_number = connected_tile.body_number
					for j in body_number_list[connected_body_number - 1].size():
						body_number_list[connected_body_number - 1][0].body_number = tile.body_number
						body_number_list[tile.body_number - 1].append(body_number_list[connected_body_number - 1][0])
						body_number_list[connected_body_number - 1].remove(0)
		
		var body_number_list_short = []
		for i in body_number_list.size():
			if body_number_list[i].size() != 0:
				body_number_list_short.append(body_number_list[i])
		
		for i in body_number_list_short.size():
			var rigid_body = RigidBody2D.new()
			get_node("rigid body").add_child(rigid_body)
			rigid_body.linear_damp = 0
			rigid_body.angular_damp = 0
			#rigid_body.bounce = 1
			rigid_body.set_script(load("res://test/ship script 2.gd"))
		
		edit_tile_list = []
		for i in body_number_list_short.size():
			var rigid_body = get_node("rigid body").get_child(i)
			var key_list_engine = []
			var object_list_engine = []
			var key_list_laser = []
			var object_list_laser = []
			
			for j in body_number_list_short[i].size():
				var tile = body_number_list_short[i][j]
				var tile_data = [tile, tile.get_parent().position, tile.get_parent().rotation, tile.get_parent().scale]
				edit_tile_list.append(tile_data)
				
				if tile.type == "Engine":
					key_list_engine.append(tile.get_child(2).get_child(0).text.split(",", false))
					object_list_engine.append(tile)
				if tile.type == "Laser" and tile.property_1 == 1:
					key_list_laser.append(tile.get_child(2).get_child(0).text.split(",", false))
					object_list_laser.append(tile)
				
				var old_area = tile.get_parent()
				old_area.remove_child(tile)
				#get_node("temporary/canvas").remove_child(old_area)
				old_area.queue_free()
				rigid_body.add_child(tile)
				tile.set_owner(rigid_body)
				tile.position = tile_data[1]
				tile.rotation = tile_data[2]
				tile.scale = tile_data[3]
			
			rigid_body.keys = key_list_engine
			rigid_body.objects = object_list_engine
			rigid_body.keys_laser = key_list_laser
			rigid_body.objects_laser = object_list_laser
	
	
	else:
		mode = "pen"
		
		for i in get_node("Control").get_child_count():
			if get_node("Control").get_child(i).name != "start engine" and get_node("Control").get_child(i).name != "FileDialog":
				get_node("Control").get_child(i).visible = true
		
		for i in edit_tile_list.size():
			var new_tile = edit_tile_list[i][0]
			var new_area = Area2D.new()
			get_node("temporary/canvas").add_child(new_area)
			new_tile.get_parent().remove_child(new_tile)
			new_area.add_child(new_tile)
			new_tile.set_owner(new_area)
			new_area.connect("mouse_entered", self, "mouse_entered_tile", [new_area])
			new_area.connect("mouse_exited", self, "mouse_exited_tile", [new_area])
			new_tile.position = Vector2(0, 0)
			new_tile.rotation = 0
			new_tile.scale = Vector2(1, 1)
			new_area.position = edit_tile_list[i][1]
			new_area.rotation = edit_tile_list[i][2]
			new_area.scale = edit_tile_list[i][3]
		
		for i in get_node("rigid body").get_child_count():
			var old_rigid_body = get_node("rigid body").get_child(0)
			get_node("rigid body").remove_child(old_rigid_body)
			old_rigid_body.queue_free()

func is_mouse_clicked():
	if Input.is_mouse_button_pressed(1) == true:
		mouse_clicked = true
	else:
		mouse_clicked = false
	if mouse_clicked != last_mouse_clicked:
		if mouse_clicked == true:
			mouse_event = true
	else:
		mouse_event = false
	last_mouse_clicked = mouse_clicked

func mouse_entered():
	dont_place_tile = true

func mouse_exited():
	dont_place_tile = false

func disable_button():
	get_node("Control/mode select").mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_node("Control/tile select").mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in get_node("Control/tile select").get_child_count():
		var tab = get_node("Control/tile select").get_child(i)
		tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for j in get_node("Control/tile select").get_child(i).get_child_count():
			var button = get_node("Control/tile select").get_child(i).get_child(j)
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in get_node("Control/tile controls").get_child_count():
		var button = get_node("Control/tile controls").get_child(i)
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable_button():
	get_node("Control/mode select").mouse_filter = Control.MOUSE_FILTER_PASS
	get_node("Control/tile select").mouse_filter = Control.MOUSE_FILTER_PASS
	for i in get_node("Control/tile select").get_child_count():
		var tab = get_node("Control/tile select").get_child(i)
		tab.mouse_filter = Control.MOUSE_FILTER_PASS
		for j in get_node("Control/tile select").get_child(i).get_child_count():
			var button = get_node("Control/tile select").get_child(i).get_child(j)
			button.mouse_filter = Control.MOUSE_FILTER_PASS
	for i in get_node("Control/tile controls").get_child_count():
		var button = get_node("Control/tile controls").get_child(i)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
	get_node("Control/start engine").mouse_filter = Control.MOUSE_FILTER_PASS



func _ready():
	set_control_pos()
	
	for i in tile_list.size():
		tile_scn.append(load("res://test/test tile scenes/" + tile_list[i] + ".tscn"))
	
	button_list.append(get_node("Control/mode select"))
	for i in get_node("Control/mode select").get_child_count():
		var button = get_node("Control/mode select").get_child(i)
		button.connect("pressed", self, "mode_button_pressed", [button])
		button_list.append(button)
	button_list.append(get_node("Control/tile select"))
	for i in get_node("Control/tile select").get_child_count():
		for j in get_node("Control/tile select").get_child(i).get_child_count():
			var button = get_node("Control/tile select").get_child(i).get_child(j)
			button.connect("pressed", self, "tile_button_pressed", [button])
			button_list.append(button)
	for i in get_node("Control/tile controls").get_child_count():
		var button = get_node("Control/tile controls").get_child(i)
		button.connect("pressed", self, "control_button_pressed", [button])
		button_list.append(button)
	get_node("Control/start engine").connect("pressed", self, "start_engine_pressed")
	
	button_list.append(get_node("Control/start engine"))
	get_node("Control/save").connect("pressed", self, "save_pressed")
	button_list.append(get_node("Control/save"))
	get_node("Control/load").connect("pressed", self, "load_pressed")
	button_list.append(get_node("Control/load"))
	
	get_node("Control/tile controls/color").connect("color_changed", self, "color_changed")
	get_node("Control/tile controls/color").get_popup().connect("about_to_show", self, "color_shown")
	get_node("Control/tile controls/color").get_popup().connect("popup_hide", self, "color_hidden")
	
	for i in button_list.size():
		button_list[i].connect("mouse_entered", self, "mouse_entered")
		button_list[i].connect("mouse_exited", self, "mouse_exited")
	
	get_node("Control/FileDialog").connect("about_to_show", self, "popup_shown")
	get_node("Control/FileDialog").connect("popup_hide", self, "popup_hidden")
	get_node("Control/FileDialog").connect("file_selected", self, "file_selected")
	
	crr_tile_type = tile_list[0]
	mouse_new_tile(crr_tile_type)
	
	set_process(true)



func _process(delta):
	set_control_pos()
	
	is_mouse_clicked()
	
	if mode != last_mode:
		if mode == "pen":
			enable_button()
		if mode == "eraser" or mode == "engine" or mode == "popup" or mode == "run" or mode == "color":
			disable_button()
			if mode == "eraser":
				get_node("Control/start engine").mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if mode == "pen":
		if last_mode != "pen":
			mouse_new_tile(crr_tile_type)
			dont_place_tile = true
			get_node("Control/tile controls/color").color = crr_color
			if current_tile.type == "Base":
				get_node("Control/tile controls/color").visible = true
		
		place_tile = mouse_event
		
		if place_tile == true and dont_place_tile == false:
			canvas_new_tile(crr_tile_type)
		
		if last_mode == "color" or last_mode == "popup":
			dont_place_tile = false
		
		if change_tile == true:
			change_tile = false
			mouse_new_tile(crr_tile_type)
		
		current_tile.position = allign_to_grid()
		current_tile.rotation = crr_tile_rotation
		current_tile.scale = crr_tile_flip
	
	if mode == "color":
		current_tile.position = allign_to_grid()
		current_tile.rotation = crr_tile_rotation
		current_tile.scale = crr_tile_flip
	
	if mode == "eraser" or mode == "engine" or mode == "popup" or mode == "run":
		get_node("Control/tile controls/color").visible = false
		
		if current_tile != null:
			current_tile.queue_free()
			current_tile = null
		
		if mode == "eraser":
			if mouse_event == true:
				if selected_tile != null:
					for i in selected_tile.get_child(0).connected_tiles.size():
						var array = selected_tile.get_child(0).connected_tiles[i].connected_tiles
						array.remove(array.find(selected_tile.get_child(0)))
					selected_tile.queue_free()
					selected_tile = null
		
		if mode == "engine":
			if mouse_event == true:
				if selected_tile != null:
					if selected_tile.get_child(0).type == "Engine" or (selected_tile.get_child(0).type == "Laser" and selected_tile.get_child(0).property_1 == 1):
						var typebox = selected_tile.get_child(0).get_child(2)
						typebox.visible = true
						typebox.rect_scale = selected_tile.scale
						var scale_int = selected_tile.scale.x * selected_tile.scale.y
						typebox.rect_rotation = -rad2deg(selected_tile.rotation) * scale_int
					if selected_tile.get_child(0).type == "Base":
						crr_color = selected_tile.get_child(0).modulate
	
	last_mode = mode