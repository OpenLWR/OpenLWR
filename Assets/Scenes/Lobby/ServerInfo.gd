extends Control

var selected_server: Control = null

func _update_info():
	if selected_server.response != null:
		$VBoxContainer/RichTextLabel.text = selected_server.response.get("motd", "no motd")
		$VBoxContainer/HBoxContainer2/Join.disabled = false
	else:
		$VBoxContainer/HBoxContainer2/Join.disabled = true
	pass

func _on_server_list_server_selected(server):
	selected_server = server
	_update_info()
	pass # Replace with function body.


func _on_server_list_server_updated(server):
	if selected_server == server:
		_update_info()
	pass # Replace with function body.

func _get_model_number(model: String):
	match model:
		"dev_test":
			return 0
		"control_room_nmp2":
			return 1
		"control_room_columbia":
			return 2

func _on_join_pressed():
	$"../../..".connect_server(selected_server.server_ip, _get_model_number(selected_server.response["model"]))
	pass # Replace with function body.
