extends Area2D

var velocity = Vector2(0, -1800)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	global_translate(velocity * delta)
