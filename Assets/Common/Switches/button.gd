extends CSGBox3D

@onready var node_3d = $"/root/Node3D"
var button 

func init():
	button = node_3d.buttons[self.name]
	button.switch = self

func _ready():
	node_3d.init_scene_objects.connect(init)
	
func button_state_change(state: bool):
	button.state = state
	# TODO: button audio
	
func button_arm_change(armed: bool):
	button.armed = armed

func switch_click(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var button = node_3d.buttons[self.name]
		button_state_change(mouse_click.pressed)
		button.updated = true

