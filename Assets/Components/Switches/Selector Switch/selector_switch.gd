extends Node3D

@onready var node_3d = $"/root/Node3D"
@onready var switch = node_3d.switches[self.name]

func switch_position_change(to_position):
	switch.position = to_position
	# TODO: switch audio
	$"selector_switch/Handle".set_rotation_degrees(Vector3(90, switch.positions[switch.position], 0))

func switch_click_left(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var switch = node_3d.switches[self.name]
		if mouse_click.pressed and (switch.position+1 in switch.positions):
			switch_position_change(switch.position+1)
			switch.updated = true

func switch_click_right(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var switch = node_3d.switches[self.name]
		if mouse_click.pressed and (switch.position-1 in switch.positions):
			switch_position_change(switch.position-1)
			switch.updated = true
