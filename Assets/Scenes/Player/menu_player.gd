extends Node2D

func _ready():
	pass
	
func _disconnect_button_pressed():
	#TODO: handle disconnecting properly
	get_tree().change_scene_to_file("res://Assets/Scenes/Lobby/new_lobby.tscn")
	
func _settings_button_pressed():
	get_node("Settings").visible = true
	
func _settings_exit_pressed():
	get_node("Settings").visible = false

func _continue_button_pressed():
	self.visible = false
