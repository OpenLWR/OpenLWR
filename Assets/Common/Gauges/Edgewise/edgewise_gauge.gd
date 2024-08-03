extends Node3D

func calculate_vertical_scale_position(indicated_value, scale_min, scale_max, meter_min_position = -22.4, meter_max_position = 22.1):
	return clamp(meter_min_position+((meter_max_position-meter_min_position)*(indicated_value-scale_min)/(scale_max-scale_min)),meter_min_position,meter_max_position)*-1
	
func set_gauge_value(value, min, max):
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($edgewise_gauge/Needle, "rotation_degrees", Vector3(-180, 0, calculate_vertical_scale_position(value, min, max)), 0.3)
	
