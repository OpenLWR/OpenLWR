extends CharacterBody3D

signal unclick_left()

@onready var Cam = $Head/Camera3d as Camera3D
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 5.0
var right_mouse_not_pressed = 0
var zoom_toggle = false

var input_dir = Vector2(0,0)
var os_is_mobile = false

@onready var config = ConfigFile.new()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if OS.get_name() in ["Android"]:
		os_is_mobile = true
		$Head/Camera3d/Move.visible = true
		$Head/Camera3d/Look.visible = true
		$Head/Camera3d/Zoom.visible = true

func _physics_process(_delta):
	var tween = get_tree().create_tween()
	if zoom_toggle:
		tween.tween_property($Head/Camera3d, "fov", 15, 0.1)
	else:
		tween.tween_property($Head/Camera3d, "fov", 75, 0.1)
	tween.play()
	
	if os_is_mobile:
		var joy = $Head/Camera3d/Look.output
		rotation.y -= (joy.x / (mouseSensibility-1150)) * config.get_value("options","mouse_sensitivity",1)
		$Head/Camera3d.rotation.x -= (joy.y / (mouseSensibility-1150)) * config.get_value("options","mouse_sensitivity",1)
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		input_dir = $"Head/Camera3d/Move".output
		
	
	# Get the input direction and handle the movement/deceleration.
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

var mb1 = false
var free_mouse = false

func _unhandled_input(event: InputEvent):
	config.load("game.cfg")
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mb1 = true #TODO: garbaj code
		
	if mb1 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mb1 = false
		unclick_left.emit()
		
	var freelook = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	
	if not config.get_value("options","pan_mode",true):
		if event.is_action_pressed("free_look"):
			free_mouse = not free_mouse
			
		if free_mouse:
			freelook = not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		else:
			freelook = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	
	
	if event is InputEventMouseMotion and freelook:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		rotation.y -= (event.relative.x / mouseSensibility) * config.get_value("options","mouse_sensitivity",1)
		$Head/Camera3d.rotation.x -= (event.relative.y / mouseSensibility) * config.get_value("options","mouse_sensitivity",1)
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	elif event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if $Head/Camera3d/Chat/Edit.has_focus():
			input_dir = Vector2(0,0)
		if event.is_action_pressed("menu_toggle"):
			get_node("Head/Camera3d/Menu").visible = not get_node("Head/Camera3d/Menu").visible
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.is_action_pressed("zoom"):
			if config.get_value("options","zoom_toggle",false) or os_is_mobile:
				zoom_toggle = not zoom_toggle
			else:
				zoom_toggle = true
		elif event.is_action_released("zoom"):
			if config.get_value("options","zoom_toggle",false) == false and not os_is_mobile:
				zoom_toggle = false
