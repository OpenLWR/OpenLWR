extends Node3D

@onready var node_3d = $"/root/Node3D"
var button = null

func init():
	button = node_3d.buttons[self.name]
	button.switch = self

func _ready():
	$"button".rotation_degrees.y = 45
	node_3d.init_scene_objects.connect(init)
	pass
	
func animate_armed(armed:bool):
	pass
	
func animate_pressed(pressed:bool):
	pass

func button_arm_change(to_position:bool):
	button.armed = to_position
	var position = 45
	if to_position:
		position = -45
	if $"button".rotation_degrees.y !=  position:
		$"button".rotation_degrees.y = position
		$"Arm".playing = true
		
func button_state_change(state):
	button.state = state
	
func button_clicked(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and button.armed and not Input.is_action_pressed("general_control_button"):
		var button = node_3d.buttons[self.name]
		button_state_change(mouse_click.pressed)
		button.updated = true
	elif mouse_click and mouse_click.button_index == 1 and Input.is_action_pressed("general_control_button") and mouse_click.pressed:
		var button = node_3d.buttons[self.name]
		button_arm_change(not button.armed)
		button.updated = true
