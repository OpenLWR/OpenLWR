extends Control

func _on_connect_button_pressed():
	print("Connect")
	var server_ip_requested = $Panel/ServerIP/TextEdit.text
	var username_requested = $Panel/Username/TextEdit.text
	print(server_ip_requested)
	print(username_requested)
	globals.server_ip_requested_tojoin = server_ip_requested
	globals.username_requested_tojoin = username_requested
	match $Panel/Scene.selected:
		0:
			get_tree().change_scene_to_file("res://node_3d.tscn")
		1:
			get_tree().change_scene_to_file("res://control_room_nmp2.tscn")
