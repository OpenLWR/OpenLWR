extends Node2D

func _ready():
	set_scene_dropdown(get_node("Scene"))

func set_scene_dropdown(dropdown):
	dropdown.add_item("Dev Test")
	dropdown.add_item("Control Room")

func connect_button_pressed():
	print("Connect")
	var server_ip_requested = get_node("ServerIP/TextEdit").text
	var username_requested = get_node("Username/TextEdit").text
	if server_ip_requested == "":
		server_ip_requested = "127.0.0.1:7001"
	print(server_ip_requested)
	print(username_requested)
	globals.server_ip_requested_tojoin = server_ip_requested
	globals.username_requested_tojoin = username_requested
	if get_node("Scene").selected == 0:
		get_tree().change_scene_to_file("res://node_3d.tscn")
	else:
		get_tree().change_scene_to_file("res://control_room_nmp2.tscn")
