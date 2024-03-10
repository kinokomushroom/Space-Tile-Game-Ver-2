extends RigidBody2D

const input_up = [10]
const input_down = [7, 8, 9]
const input_left = [15]
const input_right = [16]
const input_c_clock = [11, 14]
const input_clock = [12, 13]
const engine_power = 1000

var force = Vector2(0, 0)
var torque = 0
var com = Vector2(0, 0)
var m = 0
var m_of_i = 0
var updated = false

func center_of_mass(child_number):
	com = Vector2(0, 0)
	for i in child_number:
		var child = get_child(i)
		com += child.position + child.com
	com /= child_number
	com.x = int(com.x)
	com.y = int(com.y)
	
	if com != Vector2(0, 0):
		translate(com)
		for i in child_number:
			get_child(i).translate(-com)

func mass_and_torque(child_number):
	m = 0
	m_of_i = 0
	for i in child_number:
		var child = get_child(i)
		var distance = child.position.length()
		m += child.mass
		m_of_i += pow(distance, 2) * child.mass
	mass = m
	inertia = m_of_i

func _ready():
	updated = true
	pass

func _integrate_forces(state):
	force = Vector2(0, 0)
	torque = 0
	var child_number = get_child_count()
	
	if updated == true:
		updated = false
		center_of_mass(child_number)
		mass_and_torque(child_number)
	translate(com)
	
	for i in child_number:
		var child = get_child(i)
		child.engine_on = false
		child.get_child(0).modulate = Color(1.0, 1.0, 1.0)
	
	if Input.is_action_pressed("test_up"):
		for i in input_up.size():
			get_child(input_up[i]).engine_on = true
	if Input.is_action_pressed("test_down"):
		for i in input_down.size():
			get_child(input_down[i]).engine_on = true
	if Input.is_action_pressed("test_left"):
		for i in input_left.size():
			get_child(input_left[i]).engine_on = true
	if Input.is_action_pressed("test_right"):
		for i in input_right.size():
			get_child(input_right[i]).engine_on = true
	if Input.is_action_pressed("test_c_clock"):
		for i in input_c_clock.size():
			get_child(input_c_clock[i]).engine_on = true
	if Input.is_action_pressed("test_clock"):
		for i in input_clock.size():
			get_child(input_clock[i]).engine_on = true
	
	for i in child_number:
		var child = get_child(i)
		if child.engine_on == true:
			var current_force = (Vector2(0, 1) * engine_power * child.property_1).rotated(child.rotation)
			var distance = child.position
			force += current_force
			var temp_torque = Vector3(current_force.x, current_force.y, 0).cross(Vector3(distance.x, distance.y, 0))
			torque += -temp_torque.z
			child.get_child(0).modulate = Color(1.0, 0.1, 0.1)
	
	force = transform.basis_xform(force)
	applied_force = force/mass
	applied_torque = torque

