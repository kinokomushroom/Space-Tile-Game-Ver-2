extends RigidBody2D

const engine_power = 3000

var keys = []
var actions = []

var force = Vector2(0, 0)
var torque = 0
var com = Vector2(0, 0)
var m = 0
var m_of_i = 0

var updated = false

func center_of_mass(child_number):
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
		translate(com)
		for i in child_number:
			get_child(i).translate(-com)

func mass_and_torque(child_number):
	m = 0
	m_of_i = 0
	for i in child_number:
		var child = get_child(i)
		var distance = (child.position + child.com.rotated(child.rotation) * Vector2(1,1).rotated(child.rotation) * child.scale.rotated(child.rotation)).length()
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
	
	for i in keys.size():
		if Input.is_action_pressed(keys[i]):
			for j in actions[i].size():
				if actions[i][j] < get_child_count():
					get_child(actions[i][j]).engine_on = true
	
	
	for i in child_number:
		var child = get_child(i)
		if child.engine_on == true and child.type == "Engine":
			var current_force = (Vector2(0, 1) * engine_power * child.property_1).rotated(child.rotation) * Vector2(1,1).rotated(child.rotation) * child.scale.rotated(child.rotation)
			var distance = child.position + child.com.rotated(child.rotation) * Vector2(1,1).rotated(child.rotation) * child.scale.rotated(child.rotation)
			force += current_force
			var temp_torque = Vector3(current_force.x, current_force.y, 0).cross(Vector3(distance.x, distance.y, 0))
			torque += -temp_torque.z
			child.get_child(0).modulate = Color(1.0, 0.1, 0.1)
	
	force = transform.basis_xform(force)
	applied_force = force/mass
	applied_torque = torque

