extends StaticBody3D

var state = false
@onready var player = $"/root/Node3D/Player"

signal updated

func _ready():
	self.input_event.connect(button_press)
	player.unclick_left.connect(un_click)
	
func un_click():
	if state == true:
		state = false
		updated.emit()
	
func button_press(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		state = mouse_click.pressed
		updated.emit()
