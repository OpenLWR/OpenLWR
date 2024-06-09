extends VBoxContainer

func _ready():
	$/root/Node3D.connect(&"chat_message", _on_chat_message)
	pass

func _on_chat_message(message: String):
	var node = Label.new()
	node.text = message
	$Messages/VBoxContainer.add_child(node)
	pass

func _on_text_edit_text_submitted(text):
	$/root/Node3D.sent_messages.append(text)
	$Edit.clear()
	$Edit.release_focus()
	pass # Replace with function body.
