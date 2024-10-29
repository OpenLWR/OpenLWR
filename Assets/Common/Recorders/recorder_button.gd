extends CSGBox3D

var state = false
@onready var player = $"/root/Node3D/Player"
@onready var button = $"StaticBody3D"

signal updated

func _ready():
	button.input_event.connect(input_event)
	player.unclick_left.connect(un_click)
	
func un_click():
	if state == true:
		state = false
		updated.emit()
	
func input_event(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		state = mouse_click.pressed
		updated.emit()
