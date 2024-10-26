extends Node3D

var interface : XRInterface

var joystick_left = Vector2(0,0)

var max_speed_x = 0.05
var max_speed_z = 0.05

func _ready() -> void:
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized:
		get_viewport().use_xr = true

func _physics_process(_delta):
	
	var direction = (transform.basis * Vector3(joystick_left[1], 0, joystick_left[0])).normalized()
	direction.x = direction.x * max_speed_x
	direction.z = direction.z * max_speed_z
	#TODO: turn based on controller/player head orientation (selectable)
	if direction:
		
		
		
		self.translate_object_local(direction)

func left_controller_joystick_input(name,value):
	if name == "primary": 
		joystick_left = value
		
	if name == "trigger" and value == 1:
		var touching = $XROrigin3D/LeftController/Hand/Area3D.get_overlapping_areas()
		
		if $XROrigin3D/LeftController/Hand/Area3D.has_overlapping_areas():
			touching[0].get_parent().switch_vr_player(touching[0].name)
		
func vr_controller_input(name,value):
	if name == "trigger" and value == 1:
		var touching = $XROrigin3D/RightController/Hand/Area3D.get_overlapping_areas()
		
		if $XROrigin3D/RightController/Hand/Area3D.has_overlapping_areas():
			touching[0].get_parent().switch_vr_player(touching[0].name)
			
		
