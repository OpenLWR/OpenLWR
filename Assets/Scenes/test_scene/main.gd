extends Node3D
var json = JSON.new()
var socket = WebSocketPeer.new()

enum client_packets {
	SWITCH_PARAMETERS_UPDATE = 2,
	BUTTON_PARAMETERS_UPDATE = 6,
	PLAYER_POSITION_PARAMETERS_UPDATE = 9,
	ROD_SELECT_UPDATE = 11,
	USER_LOGIN = 12,
}

enum server_packets {
	METER_PARAMETERS_UPDATE = 0,
	USER_LOGOUT = 1,
	SWITCH_PARAMETERS_UPDATE = 3,
	INDICATOR_PARAMETERS_UPDATE = 4,
	ALARM_PARAMETERS_UPDATE = 5,
	BUTTON_PARAMETERS_UPDATE = 7,
	PLAYER_POSITION_PARAMETERS_UPDATE = 8,
}

@onready var gauges = {
	"test_gauge": {
		"node": $"test_gauge",
		"value": 0.1,
		"min_value": 0,
		"max_value": 1,
	},
}

var switches = {
	"test_switch": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
	},
	"test_switch2": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
	},
}

var buttons = {
	"test_button": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	}
}

enum annunciator_state {
	CLEAR = 0,
	ACTIVE = 1,
	ACKNOWLEDGED = 2,
	ACTIVE_CLEAR = 3,
}

var alarms = {
	"test_alarm": {
		"box": "Box1",
		"window": "A1",
		"state": annunciator_state.CLEAR,
		"material": null,
	},
}

@onready var indicators = {
	"lamp_test": $"indicator".get_material()
}

@onready var players = {
	#"1":{ #key is userid, for now its username
	#	"position" : {"x" : 0, "y" : 0, "z" : 0,}, # Can we use a Vector3 here?
	#	"username" : "john",
	#	"object" : null, #player object to manipulate, 
	#}
}

var selected_rod = null

var connection_ready = false

const remote_player_scene = preload("res://Assets/Scenes/Player/remote_player.tscn")

func build_packet(packet_id, data):
	return "%s|%s" % [str(packet_id), Marshalls.utf8_to_base64(data)]
	
func disconnected(socket):
	var code = socket.get_close_code()
	var reason = socket.get_close_reason()
	print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
	#kick to lobby screen
	get_tree().change_scene_to_file("res://Assets/Scenes/Lobby/lobby.tscn")
	set_process(false) # Stop processing.

func _ready(): # assume here that the scene was called by the lobby screen
	var endpoint = "ws://%s:7001/ws" % [globals.server_ip_requested_tojoin] # TODO: should token be generated on server-side?
	socket.connect_to_url(endpoint)
	var state = socket.get_ready_state()
	
	while state != WebSocketPeer.STATE_OPEN:
		await get_tree().create_timer(0.1).timeout
		
	var err = socket.send_text(build_packet(client_packets.USER_LOGIN, globals.username_requested_tojoin))
	if err: 
		disconnected(socket) 
	else:
		connection_ready = true
	for alarm in alarms:
		alarm = alarms[alarm]
		alarm["material"] = get_node(alarm["box"]+"/Box/Windows/"+alarm["window"]).get_material()
	
	
func parse_b64(b64):
	return Marshalls.base64_to_utf8(b64)

func _process(delta):
	if connection_ready:
		socket.poll()
		var state = socket.get_ready_state()
		globals.connection_state = state
		if state == WebSocketPeer.STATE_OPEN:
			# check if any switches have been turned
			var updated_switches = {}
			for switch_name in switches:
				var switch = switches[switch_name]
				if switch.updated == true:
					updated_switches[switch_name] = switch.position
			
			# if switches have been turned, send them to the server
			if updated_switches != {}:
				var err = socket.send_text(build_packet(client_packets.SWITCH_PARAMETERS_UPDATE, json.stringify(updated_switches)))
				if not err:
					for switch in updated_switches:
						switches[switch].updated = false
				else:
					print(err)
					
			#check if any buttons have been pressed
			
			var updated_buttons = {}
			for button_name in buttons:
				var button = buttons[button_name]
				if button.updated == true:
					updated_buttons[button_name] = button.state
					
			if updated_buttons != {}:
				var err = socket.send_text(build_packet(client_packets.BUTTON_PARAMETERS_UPDATE, json.stringify(updated_buttons)))
				if not err:
					for button in updated_buttons:
						buttons[button].updated = false
				else:
					print(err)
					
			# TODO: only fire to server when our position updated
			
			if selected_rod != null:
				var err = socket.send_text(build_packet(client_packets.ROD_SELECT_UPDATE, json.stringify(selected_rod)))
				if not err:
					selected_rod = null
				else:
					print(err)
			
			var local_player_position = {}
			
			var local_player = get_node("Player")
			
			local_player_position = {globals.username_requested_tojoin : {
				"x" : local_player.position["x"],
				"y" : local_player.position["y"],
				"z" : local_player.position["z"],
			}}
			
			if local_player_position != {} and (
			globals.last_sent_x != local_player.position["x"]
			or globals.last_sent_y != local_player.position["y"]
			or globals.last_sent_z != local_player.position["z"]):
				globals.last_sent_x = local_player.position["x"]
				globals.last_sent_y = local_player.position["y"]
				globals.last_sent_z = local_player.position["z"]
				var err = socket.send_text(build_packet(client_packets.PLAYER_POSITION_PARAMETERS_UPDATE, json.stringify(local_player_position)))
				if err:
					print(err)
					
			#TODO: add a script on each remote player that updates their own position (?)
			
			for player in players:
				var player_object = get_node(player)
				var player_position = players[player].position
				player_object.position['x'] = player_position['x']
				player_object.position['y'] = player_position['y']
				player_object.position['z'] = player_position['z']
				
			# recieve packets
			while socket.get_available_packet_count():
				var packet = socket.get_packet().get_string_from_utf8().split("|")
				var packet_id = int(packet[0])
				var packet_data = parse_b64(packet[1])
				match packet_id:
					server_packets.METER_PARAMETERS_UPDATE:
						# data: a dict of all indicator values, json
						packet_data = json.parse_string(packet_data)
						for gauge in packet_data:
							var value = packet_data[gauge]
							gauges[gauge].value = value
							gauges[gauge].node.set_needle_position(gauges[gauge].value, gauges[gauge].min_value, gauges[gauge].max_value)
					
					server_packets.USER_LOGOUT:
						# data: the username of the person who logged out, string
						print("User %s logged out." % [packet_data])
						
					server_packets.SWITCH_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for switch in packet_data:
							var position = packet_data[switch]
							if switches[switch].switch != null:
								switches[switch].switch.switch_position_change(position)
					
					server_packets.INDICATOR_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for indicator in packet_data:
							var indicator_state = packet_data[indicator]
							indicators[indicator].emission_enabled = indicator_state
							print(indicator)
							
					server_packets.ALARM_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for alarm in packet_data:
							var alarm_state = packet_data[alarm]
							alarms[alarm].state = int(alarm_state)
							
					server_packets.BUTTON_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for button in packet_data:
							var button_state = packet_data[button]
							if buttons[button].switch != null:
								buttons[button].switch.button_state_change(button_state)
								print(button)
					
					server_packets.PLAYER_POSITION_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data) # dict of all players, dict OR Vector3(?) of position
						for player in packet_data:
							var player_position = packet_data[player]
							
							if player == globals.username_requested_tojoin:
								break #if the player is ourselves, ignore it
							
							if player in players:
								players[player].position = player_position
								
							else:
								# player is not in our list, assume its a new player and insert a new entry
								players[player] = {
									"position" : player_position,
								}
								# actually create the other player character
								var NewRemotePlayer = remote_player_scene.instantiate()
								NewRemotePlayer.name = player
								self.add_child(NewRemotePlayer)
								# TODO: remove remote player instance when they disconnect
								
					
					
		elif state == WebSocketPeer.STATE_CLOSING:
			# Keep polling to achieve proper close.
			pass
		elif state == WebSocketPeer.STATE_CLOSED:
			disconnected(socket)
