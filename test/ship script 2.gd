extends RigidBody2D

const engine_power = 5000

var keys = []
var objects = []
var keys_laser = []
var objects_laser = []

var laser_time = []
const laser_time_min = 0.2

var force = Vector2(0, 0)
var torque = 0
var com = Vector2(0, 0)
var m = 0
var m_of_i = 0

var laser_scn

var updated = true

func center_of_mass(child_number, state):
	com = Vector2(0, 0)
	var com_1 = Vector2(0, 0)
	var com_2 = 0
	for i in child_number:
		var child = get_child(i)
		com_1 += child.mass * (child.position + child.com.rotated(child.rotation) * Vector2(1,1).rotated(child.rotation) * child.scale.rotated(child.rotation))
		com_2 += child.mass
	com = com_1 / com_2
	com.x = int(com.x)
	com.y = int(com.y)

	if com != Vector2(0, 0):
		for i in child_number:
			get_child(i).translate(-com)
		state.transform.origin += com

func mass_and_torque(child_number, state):
	m = 0
	m_of_i = 0
	for i in child_number:
		var child = get_child(i)
		var distance = (child.position + child.com.rotated(child.rotation) * Vector2(1,1).rotated(child.rotation) * child.scale.rotated(child.rotation)).length()
		m += child.mass
		m_of_i += child.moi + child.mass * pow(distance, 2)
	mass = m
	inertia = m_of_i

func _ready():
	pass

func _integrate_forces(state):
	force = Vector2(0, 0)
	torque = 0
	var child_number = get_child_count()
	
	if updated == true:
		updated = false
		
		center_of_mass(child_number, state)
		mass_and_torque(child_number, state)
		
		for i in objects_laser.size():
			laser_time.append(0)
		set_process(true)
		laser_scn = load("res://test/laser.tscn")
	
	for i in child_number:
		var child = get_child(i)
		child.engine_on = false
		if child.type == "Engine":
			child.get_child(0).get_child(0).visible = false
	
	for i in objects_laser.size():
		for j in keys_laser[i].size():
			if Input.is_action_pressed(keys_laser[i][j]):
				if laser_time[i] >= laser_time_min:
					laser_time[i] = 0
					var new_laser = laser_scn.instance()
					get_parent().add_child(new_laser)
					var shooter = objects_laser[i]
					new_laser.position = shooter.global_position
					new_laser.rotation = shooter.rotation + rotation
					new_laser.scale = shooter.scale
					new_laser.velocity = (new_laser.velocity * shooter.scale).rotated(new_laser.rotation)
					new_laser.velocity += linear_velocity
					new_laser.velocity += (global_position - shooter.global_position).rotated(-PI/2) * angular_velocity
	
	for i in objects.size():
		for j in keys[i].size():
			if Input.is_action_pressed(keys[i][j]):
				objects[i].engine_on = true
	
	for i in child_number:
		var child = get_child(i)
		if child.engine_on == true and child.type == "Engine":
			var current_force = (Vector2(0, 1) * engine_power * child.property_1).rotated(child.rotation) * Vector2(1,1).rotated(child.rotation) * child.scale.rotated(child.rotation)
			var distance = child.position + child.com.rotated(child.rotation) * Vector2(1,1).rotated(child.rotation) * child.scale.rotated(child.rotation)
			force += current_force
			var temp_torque = Vector3(current_force.x, current_force.y, 0).cross(Vector3(distance.x, distance.y, 0))
			torque += -temp_torque.z
			child.get_child(0).get_child(0).visible = true
			child.get_child(0).get_child(0).modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	force = transform.basis_xform(force)
	applied_force = force
	applied_torque = torque

func _process(delta):
	for i in laser_time.size():
		laser_time[i] += delta