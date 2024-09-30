extends Control

@onready var config = ConfigFile.new()

func _ready():
	config.load("game.cfg")
	for option in config.get_section_keys("options"):
		var setting = get_node_or_null(option)
		if setting == null:
			continue
		var value = config.get_value("options",option)
		if setting is HSlider:
			setting.set_value_no_signal(value)
		else:
			setting.set_pressed_no_signal(value)

func option(value,name):
	config.set_value("options",name,value)
	config.save("game.cfg")
