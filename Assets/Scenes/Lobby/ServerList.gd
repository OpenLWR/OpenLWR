extends Control

signal server_selected(server: Control)
signal server_updated(server: Control)

const item_scene = preload("res://Assets/Scenes/Lobby/LobbyItem.tscn")
@onready var list = $PanelContainer/ScrollContainer/VBoxContainer


var known_servers = []

func _add_server(ip, server_name):
	var item = item_scene.instantiate()
	item.server_ip = ip
	item.server_name = server_name
	item.focus_entered.connect(_on_server_focused.bind(item))
	item.ping_complete.connect(_on_ping_success.bind(item))
	item.ping_fail.connect(_on_ping_fail.bind(item))
	known_servers.append(item)
	list.add_child(item)
	pass

func _ready():
	_add_server("127.0.0.1:7001", "Local server")
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
