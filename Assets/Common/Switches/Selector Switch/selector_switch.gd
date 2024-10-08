
extends Node3D

@onready var node_3d = $"/root/Node3D"
@onready var player = $"/root/Node3D/Player"
var switch = null
@onready var rotate_opposite = get_node_or_null("rotate_opposite") != null
@onready var has_flag = get_node_or_null("selector_switch/Flag")
var flag_green = null
var flag_red = null

func init():
	switch = node_3d.switches[self.name]
	switch.switch = self
	switch.local_push = false
	player.unclick_left.connect(switch_unclick)
	if switch.lights != {}:
		for light in switch.lights:
			if light == "green" or light == "red":
				#this is so we dont have to make every light unique
				var light_material = get_node(light+"/Lamp").get_material().duplicate()
				get_node(light+"/Lamp").material = light_material
				light_material.emission_enabled = switch["lights"][light]
				switch["lights"][light] = light_material
			else:
				var light_material = get_node(light).get_material().duplicate()
				get_node(light).material = light_material
				light_material.emission_enabled = switch["lights"][light]
				switch["lights"][light] = light_material
				
	if has_flag:
		switch["flag"] = "green"
		#preload the materials here, if it has a flag
		flag_green = preload("res://Assets/Materials/green_flag.tres")
		flag_red = preload("res://Assets/Materials/red_flag.tres")
		
	switch_position_change(switch["position"],true)

func _ready():
	node_3d.init_scene_objects.connect(init)

func switch_position_change(to_position: int,nosound: bool = false):
	switch.position = to_position
	var rotate_position = switch.positions[switch.position]
	var handle_rotation = round($"selector_switch/Handle".rotation_degrees.y)
	
	# used in the case where a switch was modeled such that it needs to be rotated the opposite direction
	if rotate_opposite:
		rotate_position = rotate_position * -1
	if handle_rotation != rotate_position:
		if not nosound:
			$"Move".playing = true
		$"selector_switch/Handle".rotation_degrees.y = rotate_position
		
	if has_flag:
		#TODO: sync flags with server		
		match switch.flag:#TODO: PTL Color (black)
			"green":
				has_flag.set_surface_override_material(0,flag_green)
			"red":
				has_flag.set_surface_override_material(0,flag_red)

func switch_click_left(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var switch = node_3d.switches[self.name]
		if mouse_click.pressed and (switch.position+1 in switch.positions):
			switch.local_push = true
			switch_position_change(switch.position+1)
			if switch.position >=2 and ("flag" in switch):
				switch.flag = "red"
			switch.updated = true

func switch_click_right(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var switch = node_3d.switches[self.name]
		if mouse_click.pressed and (switch.position-1 in switch.positions):
			switch.local_push = true
			switch_position_change(switch.position-1)
			if switch.position <=0 and ("flag" in switch):
				switch.flag = "green"
			switch.updated = true
			
func switch_unclick():
	var switch = node_3d.switches[self.name]
	if switch.local_push and switch.momentary:
		switch_position_change(1)
		switch.updated = true

func switch_click_ptl(_camera, event, _position, _normal, _shape_idx):
	print("pull to lock") #TODO

func switch_vr_player(name):
	
	if name == "VRInteractionZoneL":
		if (switch.position+1 in switch.positions):
			switch_position_change(switch.position+1)
			if switch.position >=2 and ("flag" in switch):
				switch.flag = "red"
			switch.updated = true
	elif name == "VRInteractionZoneR":
		if (switch.position-1 in switch.positions):
			switch_position_change(switch.position-1)
			if switch.position <=0 and ("flag" in switch):
				switch.flag = "green"
			switch.updated = true
