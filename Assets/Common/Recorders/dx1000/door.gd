extends MeshInstance3D

var open = false
var is_pressed = false

@onready var player = $"/root/Node3D/Player"

func _ready():
	$"StaticBody3D".input_event.connect(door_clicked)
	player.unclick_left.connect(un_click)

func un_click():
	if is_pressed == true:
		is_pressed = false

func door_clicked(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed and is_pressed == false:
		is_pressed = true
		if open:
			var tween = get_tree().create_tween()
			tween.set_parallel()
			tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 0), 0.6)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.set_ease(Tween.EASE_IN_OUT)
			$close.play()
			tween.play()
		else:
			var tween = get_tree().create_tween()
			tween.set_parallel()
			tween.tween_property(self, "rotation_degrees", Vector3(0, 0, -170), 1)
			$open.play()
			tween.play()
		open = not open
		
			
