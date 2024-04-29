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
	ROD_POSITION_PARAMETERS_UPDATE = 10,
	USER_LOGIN_ACK = 13,
}

@onready var gauges = {}

var switches = {
	"reactor_mode_switch": {
		"switch": null,
		"positions": {
			0: 45, #Shutdown
			1: 0, #Refuel
			2: -45, #Startup
			3: -90, #Run
		},
		"position": 0,
		"momentary": false,
		"updated": false,
	},
}

var buttons = {
	"SCRAM_A1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"SCRAM_B1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"SCRAM_A2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"SCRAM_B2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"ALARM_SILENCE_1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"ALARM_ACK_1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"ALARM_RESET_1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"ACCUM_TROUBLE_RESET": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"ROD_DRIFT_RESET": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
}

enum annunciator_state {
	CLEAR = 0,
	ACTIVE = 1,
	ACKNOWLEDGED = 2,
	ACTIVE_CLEAR = 3,
}

var alarms = {
	"rps_a_auto_trip": {
		"box": "Box1",
		"window": "B2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rps_b_auto_trip": {
		"box": "Box4",
		"window": "B2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rod_drive_accumulator_trouble": {
		"box": "Box4",
		"window": "A6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"control_rod_out_block": {
		"box": "Box4",
		"window": "B6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"control_rod_drift": {
		"box": "Box4",
		"window": "C6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
}

var alarm_groups = {
	"1" : {"F" : true, "S" : true}, # F - Fast S - Slow
}

@onready var indicators = {
	"SCRAM_SOLENOID_A": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_A/Lamp".get_material(),
	"SCRAM_SOLENOID_B": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_B/Lamp".get_material(),
	"SCRAM_SOLENOID_C": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_C/Lamp".get_material(),
	"SCRAM_SOLENOID_D": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_D/Lamp".get_material(),
	"SCRAM_SOLENOID_E": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_E/Lamp".get_material(),
	"SCRAM_SOLENOID_F": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_F/Lamp".get_material(),
	"SCRAM_SOLENOID_G": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_G/Lamp".get_material(),
	"SCRAM_SOLENOID_H": $"Control Room Panels/Main Panel Center/Controls/ScramCircuits/SCRAM_SOLENOID_H/Lamp".get_material(),
	
	"RMCS_WITHDRAW_BLOCK": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_WITHDRAW_BLOCK".get_material(),
	
}

var rod_information = {}

@onready var players = {
	#"1":{ #key is userid, for now its username
	#	"position" : {"x" : 0, "y" : 0, "z" : 0,}, # Can we use a Vector3 here?
	#	"username" : "john",
	#	"object" : null, #player object to manipulate, 
	#}
}

var selected_rod = null
@onready var tween = get_tree().create_tween()

var connection_ready = false
var connection_packet_sent = false

const remote_player_scene = preload("res://Scenes/Player/remote_player.tscn")

func build_packet(packet_id, data):
	return "%s|%s" % [str(packet_id), Marshalls.utf8_to_base64(data)]

func build_rod_select():
	for rod in rod_information:
		var button = buttons["select_%s" % rod]
		
func disconnected(socket):
	var code = socket.get_close_code()
	var reason = socket.get_close_reason()
	print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
	#kick to lobby screen
	get_tree().change_scene_to_file("res://lobby.tscn")
	set_process(false) # Stop processing.

func _ready(): # assume here that the scene was called by the lobby screen
	build_rod_select()
	var endpoint = "ws://%s/ws" % [globals.server_ip_requested_tojoin] # TODO: should token be generated on server-side?
	socket.connect_to_url(endpoint)

	for alarm in alarms:
		alarm = alarms[alarm]
		alarm["material"] = get_node("Annunciators/"+alarm["box"]+"/Box/Windows/"+alarm["window"]).get_material()
	

	
func parse_b64(b64):
	return Marshalls.base64_to_utf8(b64)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	globals.connection_state = state
	if connection_ready:
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
						print(button)
				else:
					print(err)
					
			# TODO: only fire to server when our position updated
			
			if selected_rod != null:
				print("a")
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
			
			if local_player_position != {}:
				var err = socket.send_text(build_packet(client_packets.PLAYER_POSITION_PARAMETERS_UPDATE, json.stringify(local_player_position)))
				if err:
					print(err)
					
			#TODO: add a script on each remote player that updates their own position (?)
			
			for player in players:
				var player_position = players[player].position
				var actual_position = players[player].object.position
				var twn = create_tween()
				twn.tween_property(players[player].object,"position",Vector3(player_position['x'],player_position['y'],player_position['z']),0.1)
				twn.set_trans(Tween.TRANS_LINEAR)
				twn.set_ease(Tween.EASE_IN_OUT)
				twn.play()
				#player_object.position['x'] = player_position['x']
				#player_object.position['y'] = player_position['y']
				#player_object.position['z'] = player_position['z']
				
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
							
					server_packets.ALARM_PARAMETERS_UPDATE:
						packet_data = packet_data.split("|")
						var alarm_dict = json.parse_string(packet_data[0])
						var groups = json.parse_string(packet_data[1])
						for alarm in alarm_dict:
							var alarm_state = alarm_dict[alarm]["state"]
							alarms[alarm].state = int(alarm_state)
							alarms[alarm].silenced = bool(alarm_dict[alarm]["silenced"])
							
						for group in groups:
							var fast_state = groups[group]["F"]
							var slow_state = groups[group]["S"]
							alarm_groups[group]["F"] = bool(fast_state)
							alarm_groups[group]["S"] = bool(slow_state)

					server_packets.ROD_POSITION_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for rod in packet_data:
							rod_information[rod] = packet_data[rod]
							
					server_packets.BUTTON_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for button in packet_data:
							var button_state = packet_data[button]
							if button not in buttons:
								continue
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
								players[player]["object"] = NewRemotePlayer
								# TODO: remove remote player instance when they disconnect
								
					server_packets.ROD_POSITION_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						rod_information = packet_data
								
					
					
		elif state == WebSocketPeer.STATE_CLOSING:
			# Keep polling to achieve proper close.
			pass
		elif state == WebSocketPeer.STATE_CLOSED:
			disconnected(socket) 
	else:
		if state == WebSocketPeer.STATE_OPEN:
			if not connection_packet_sent:
				var err = socket.send_text(build_packet(client_packets.USER_LOGIN, globals.username_requested_tojoin))
				if err: 
					disconnected(socket) 
				else:
					connection_packet_sent = true
				
			while socket.get_available_packet_count():
				var packet = socket.get_packet().get_string_from_utf8().split("|")
				var packet_id = int(packet[0])
				var packet_data = parse_b64(packet[1])
				
				if packet_id == server_packets.USER_LOGIN_ACK:
					connection_ready = true
