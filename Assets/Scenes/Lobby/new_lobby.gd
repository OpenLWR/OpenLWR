extends Control

func connect_server(ip: String, requested_scene: int):
	print("Connect")
	var server_ip_requested = ip
	var username_requested = "clx0"
	print(server_ip_requested)
	print(username_requested)
	globals.server_ip_requested_tojoin = server_ip_requested
	globals.username_requested_tojoin = username_requested
	
	match 2:
		0:
			get_tree().change_scene_to_file("res://Assets/Scenes/Test Scene/test_scene.tscn")
		1:
			get_tree().change_scene_to_file("res://Assets/Scenes/Nine Mile Point Unit 2/control_room_nmp2.tscn")
		2:
			get_tree().change_scene_to_file("res://Assets/Scenes/Columbia/control_room_columbia.tscn")


func _on_h_split_container_dragged(offset):
	pass # Replace with function body.


