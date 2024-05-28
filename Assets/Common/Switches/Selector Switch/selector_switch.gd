extends Node3D

@onready var node_3d = $"/root/Node3D"
@onready var switch = node_3d.switches[self.name]
@onready var rotate_opposite = get_node_or_null("rotate_opposite") != null

func _ready():
	switch.switch = self
	
	if switch.lights != {}:
		for light in switch.lights:
			if light == "green" or light == "red":
				switch["lights"][light] = get_node(light+"/Lamp").get_material()
			else:
				switch["lights"][light] = get_node(light).get_material()
			
func switch_position_change(to_position: int):
	switch.position = to_position
	var rotate_position = switch.positions[switch.position]
	var handle_rotation = round($"selector_switch/Handle".rotation_degrees.y)
	
	# used in the case where a switch was modeled such that it needs to be rotated the opposite direction
	if rotate_opposite:
		rotate_position = rotate_position * -1
	if handle_rotation != rotate_position:
		$"Move".playing = true
		$"selector_switch/Handle".rotation_degrees.y = rotate_position

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
