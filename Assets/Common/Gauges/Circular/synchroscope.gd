extends Node3D
	
func set_gauge_value(value, min, max):
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($Circular/Needle, "rotation_degrees", Vector3(0, value, 0), 0.3)
	
