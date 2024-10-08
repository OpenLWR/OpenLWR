extends Node2D

func _ready():
	pass
	
func _disconnect_button_pressed():
	$"/root/Node3D"._disconnect()
	
func _settings_button_pressed():
	get_node("Settings").visible = true
	
func _settings_exit_pressed():
	get_node("Settings").visible = false

func _continue_button_pressed():
	self.visible = false

func bug_report_pressed():
	OS.shell_open("https://github.com/OpenLWR/OpenLWR/issues") 
