extends Control

func connect_server(ip: String, requested_scene: String):

	var server_ip_requested = ip
	var username_requested = $Panel/HSplitContainer/Control/HBoxContainer/ServerInfo/VBoxContainer/HBoxContainer/LineEdit.text
	globals.server_ip_requested_tojoin = server_ip_requested
	globals.username_requested_tojoin = username_requested
	globals.use_vr = $Panel/HSplitContainer/Control/HBoxContainer/ServerInfo/VBoxContainer/HBoxContainer/VREnable.button_pressed
	
	if ResourceLoader.exists("res://Assets/Scenes/%s/control_room.tscn" % requested_scene):
		get_tree().change_scene_to_file("res://Assets/Scenes/%s/control_room.tscn" % requested_scene)
	else:
		print("This scene doesnt exist, we cant change to it")


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
		$Panel/HSplitContainer/Control/HBoxContainer/ServerInfo/VBoxContainer/HBoxContainer/LineEdit.text = arguments.username
	if arguments.has("scene"):
		djoin_scene = int(arguments.scene)
	if arguments.has("join"):
		if not arguments.join.is_empty():
			djoin_ip = arguments.join
		connect_server(djoin_ip, djoin_scene)
		
	if globals.disconnect_msg != "":
		$KickMessage/VBoxContainer/Name/Label.text = "You were disconnected with reason:\n%s" % globals.disconnect_msg
		$KickMessage.popup()
		globals.disconnect_msg = ""
		
	pass

func _on_add_server_pressed():
	$"Add server".popup()
	pass # Replace with function body.


func _on_line_edit_text_changed(username):
	var username_valid = len(username) <= 20 and len(username) >= 2
	$Panel/HSplitContainer/Control/HBoxContainer/ServerInfo/VBoxContainer/HBoxContainer2/Join.disabled = not username_valid
	$Panel/HSplitContainer/Control/HBoxContainer/ServerInfo/VBoxContainer/InvalidUser.visible = not username_valid
