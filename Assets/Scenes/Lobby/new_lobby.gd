extends Control

func connect_server(ip: String, requested_scene: int):
	print("Connect")
	var server_ip_requested = ip
	var username_requested = $Panel/HSplitContainer/ServerInfo/VBoxContainer/HBoxContainer/LineEdit.text
	print(server_ip_requested)
	print(username_requested)
	globals.server_ip_requested_tojoin = server_ip_requested
	globals.username_requested_tojoin = username_requested
	
	match requested_scene:
		0:
			get_tree().change_scene_to_file("res://Assets/Scenes/Test Scene/test_scene.tscn")
		1:
			get_tree().change_scene_to_file("res://Assets/Scenes/Nine Mile Point Unit 2/control_room_nmp2.tscn")
		2:
			get_tree().change_scene_to_file("res://Assets/Scenes/Columbia/control_room_columbia.tscn")

func _parse_arguments() -> Dictionary:
	var arguments = {}
	for argument in OS.get_cmdline_user_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.lstrip("--")] = ""
	return arguments

func _ready():
	var arguments = _parse_arguments()
	var djoin_scene = 2
	var djoin_ip = "127.0.0.1:7001"
	if arguments.has("username"):
		$Panel/HSplitContainer/ServerInfo/VBoxContainer/HBoxContainer/LineEdit.text = arguments.username
	if arguments.has("scene"):
		djoin_scene = int(arguments.scene)
	if arguments.has("join"):
		if not arguments.join.is_empty():
			djoin_ip = arguments.join
		connect_server(djoin_ip, djoin_scene)
	pass

func _on_add_server_pressed():
	$"Add server".popup()
	pass # Replace with function body.
