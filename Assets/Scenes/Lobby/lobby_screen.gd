extends Control

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
	
	if arguments.has("username"):
		$Panel/Username/TextEdit.text = arguments.username
	if arguments.has("scene"):
		$Panel/Scene.select(int(arguments.scene))
	if arguments.has("join"):
		if not arguments.join.is_empty():
			$Panel/ServerIP/TextEdit.text = arguments.join
		_on_connect_button_pressed()
	pass

func use_vr(toggle):
	globals.use_vr = toggle

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
			get_tree().change_scene_to_file("res://Assets/Scenes/Test Scene/test_scene.tscn")
		1:
			get_tree().change_scene_to_file("res://Assets/Scenes/Nine Mile Point Unit 2/control_room_nmp2.tscn")
		2:
			get_tree().change_scene_to_file("res://Assets/Scenes/Columbia/control_room_columbia.tscn")
