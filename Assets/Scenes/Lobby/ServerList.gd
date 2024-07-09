extends Control

@onready var config = ConfigFile.new()


signal server_selected(server: Control)
signal server_updated(server: Control)

const item_scene = preload("res://Assets/Scenes/Lobby/LobbyItem.tscn")
@onready var list = $PanelContainer/ScrollContainer/VBoxContainer

var selected_server: Control = null

var known_servers = []


func add_server(ip: String, server_name: String):
	var cfg = config.get_value("server_browser","servers")
	cfg[server_name] = ip
	config.set_value("server_browser","servers",cfg)
	config.save("game.cfg")
	add_server_internal(ip,server_name)
	pass

func add_server_internal(ip: String, server_name: String):
	var item = item_scene.instantiate()
	item.server_ip = ip
	item.server_name = server_name
	item.focus_entered.connect(_on_server_focused.bind(item))
	item.ping_complete.connect(_on_ping_success.bind(item))
	item.ping_fail.connect(_on_ping_fail.bind(item))
	known_servers.append(item)
	list.add_child(item)
	pass

func _add_initial_servers():
	for server in config.get_value("server_browser","servers"):
		if typeof(server) == TYPE_INT:
			continue
		add_server_internal(config.get_value("server_browser","servers")[server],server)
		
	pass

func _ready():
	var err = config.load("game.cfg")
	if not err and config.get_value("server_browser","servers") != null:
		_add_initial_servers()
	elif config.get_value("server_browser","servers") == null:
		#for whatever reason, whenever the table is empty, it defaults to a table. This sits in the config to keep it a table.
		config.set_value("server_browser","servers",{"Local Server":"127.0.0.1:7001",1:1}) #use a integer because the client cant input an integer
		config.save("game.cfg")
		_add_initial_servers()
		
	pass

func _on_ping_fail(server: Control):
	server_updated.emit(server)
	pass

func _on_ping_success(server: Control):
	server_updated.emit(server)
	pass

func _on_server_focused(server: Control):
	#$"../../..".connect_server(server.server_ip, 2)
	server_selected.emit(server)
	pass


func _on_server_selected(server):
	selected_server = server
	$HBoxContainer/Remove.disabled = server == null
	pass # Replace with function body.


func _on_remove_pressed():
	$PanelContainer/ScrollContainer/VBoxContainer.remove_child(selected_server)
	var deleted_server = selected_server
	#erase from the config
	var cur_config = config.get_value("server_browser","servers")
	cur_config = cur_config.erase(deleted_server.server_name)
	config.set_value("server_browser","servers",cur_config)
	config.save("game.cfg")
	
	server_selected.emit(null)
	deleted_server.queue_free()
	pass # Replace with function body.
