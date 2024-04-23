extends CSGBox3D

@onready var node_3d = $"/root/Node3D"
@onready var button = node_3d.buttons[self.name]

func _ready():
	button.switch = self
	


func button_state_change(state: bool):
	button.position = state
	button.updated = true
	# TODO: button audio

func switch_click(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var button = node_3d.buttons[self.name]
		button_state_change(mouse_click.pressed)
