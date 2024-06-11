extends VBoxContainer

const MAX_CHAT_MESSAGES = 200

func _ready():
	$/root/Node3D.connect(&"chat_message", _on_chat_message)
	pass

func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if not $Edit.get_global_rect().has_point(event.position):
			$Edit.release_focus()
	pass

func _on_chat_message(message: String):
	var node = Label.new()
	node.text = message
	$Messages/VBoxContainer.add_child(node)
	var child_count = $Messages/VBoxContainer.get_child_count()
	if child_count > MAX_CHAT_MESSAGES:
		var del = $Messages/VBoxContainer.get_child(0)
		$Messages/VBoxContainer.remove_child(del)
		del.queue_free()
	await get_tree().process_frame
	#HACK: this seems like the only way to scroll to the most recent chat
	# message in the same frame
	$Messages.scroll_vertical = 21 * child_count - 230
	$AnimationPlayer.seek(0)
	$AnimationPlayer.play($AnimationPlayer.assigned_animation)
	pass

func _on_mouse_enter_or_leave(entered: bool):
	$AnimationPlayer.seek(0)
	$AnimationPlayer.play("opaque" if entered else "fade")
	pass

func _on_text_edit_text_submitted(text):
	$/root/Node3D.sent_messages.append(text)
	$Edit.clear()
	$Edit.release_focus()
	pass # Replace with function body.
