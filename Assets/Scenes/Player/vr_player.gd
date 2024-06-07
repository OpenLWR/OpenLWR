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
	#TODO: turn based on controller/player head orientation (selectable)
	if direction:
		self.position.x += direction.x * max_speed_x
		self.position.z += direction.z * max_speed_z

func left_controller_joystick_input(name,value):
	if name == "primary": 
		joystick_left = value
		
func vr_controller_input(name,value):
	print(name,value)
	if name == "grip" and value == 1:
		var touching = $XROrigin3D/RightController/Hand/Area3D.get_overlapping_areas()
		
		if $XROrigin3D/RightController/Hand/Area3D.has_overlapping_areas():
			#print("yo grabbing the switch boy")
			#is there a better way to get the hand rotation, like through OpenXR?
			#var hand_rotation = $XROrigin3D/RightController.rotation_degrees.y
			#var hand_rotation = $XROrigin3D/RightController.global_rotation_degrees.y
			var hand_position = $XROrigin3D/RightController.global_position
			touching[0].get_parent().switch_vr_player(hand_position)
			
		
