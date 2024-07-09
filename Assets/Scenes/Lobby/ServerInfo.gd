extends Control

var selected_server: Control = null

func _update_info():
	if not _verify_server() or selected_server.response == null:
		$VBoxContainer/RichTextLabel.text = "Connection error or no server selected\n<--- Select a server to begin"
		$VBoxContainer/HBoxContainer2/Join.disabled = true
	else:
		$VBoxContainer/RichTextLabel.text = selected_server.response.get("motd", "no motd")
		$VBoxContainer/HBoxContainer2/Join.disabled = false
	pass

func _verify_server() -> bool:
	if not is_instance_valid(selected_server):
		selected_server = null
	return selected_server != null

func _on_server_list_server_selected(server):
	selected_server = server
	_update_info()
	pass # Replace with function body.


func _on_server_list_server_updated(server):
	if selected_server == server:
		_update_info()
	pass # Replace with function body.

func _on_join_pressed():
	if not _verify_server():
		return
	$"../../..".connect_server(selected_server.server_ip, selected_server.response["model"])
	pass # Replace with function body.
