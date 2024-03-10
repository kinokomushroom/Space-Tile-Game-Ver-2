extends CollisionPolygon2D

export(String) var tile_name
export(String, "Base", "Cockpit", "Engine", "Fuel", "Laser") var type
export(float) var mass
export(Vector2) var com
export(float) var moi
export(float) var property_1
export(float) var property_2
var tile_num
var engine_on = false
var connected_tiles = []
var body_number = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
