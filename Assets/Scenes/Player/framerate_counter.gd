extends Label
@onready var node3d = $/root/Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = str("FPS: " + str(int(Engine.get_frames_per_second())) + "\nFull: " + str(node3d.connection_ready))
