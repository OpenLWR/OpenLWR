extends Node3D

@onready var node_3d = $"/root/Node3D"
@onready var player = $"/root/Node3D/Player"
var button 

func init():
	button = node_3d.buttons[self.name]
	button.switch = self
	button.local_push = false

func _ready():
	node_3d.init_scene_objects.connect(init)
	player.unclick_left.connect(un_click)
	
func button_state_change(state: bool):
	button.state = state
	# TODO: button audio
	
func button_arm_change(armed: bool):
	button.armed = armed

func un_click():
	var button = node_3d.buttons[self.name]
	if button.local_push == true:
		button_state_change(false)
		button.updated = true

func switch_click(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var button = node_3d.buttons[self.name]
		button.local_push = mouse_click.pressed
		button_state_change(mouse_click.pressed)
		button.updated = true

