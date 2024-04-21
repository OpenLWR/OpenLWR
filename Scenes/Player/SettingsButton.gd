extends StaticBody2D

func _on_input_event(viewport, event, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		if mouse_click.pressed:
			%"ConnectionState".visible = not %"ConnectionState".visible
