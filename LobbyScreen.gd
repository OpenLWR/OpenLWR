extends Node2D


func connect_button_pressed():
	print("Connect")
	var server_ip_requested = get_node("ServerIP/TextEdit").text
	var username_requested = get_node("Username/TextEdit").text
	print(server_ip_requested)
	print(username_requested)
	globals.server_ip_requested_tojoin = server_ip_requested
	globals.username_requested_tojoin = username_requested
	get_tree().change_scene_to_file("res://node_3d.tscn")
