extends Node3D
var json = JSON.new()
var socket = WebSocketPeer.new()

enum client_packets {
	SWITCH_PARAMETERS_UPDATE = 2,
	BUTTON_PARAMETERS_UPDATE = 6,
	PLAYER_POSITION_PARAMETERS_UPDATE = 9,
	ROD_SELECT_UPDATE = 11,
	USER_LOGIN = 12,
	SYNCHRONIZE = 14,
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

@onready var gauges = {
	"four_rod_br": {
		"value": 1,
		"atypical" : true, #The min/maxes dont apply. This is simply used for receiving a value.
		"text" : false, #Is handled differently than regular gauges. Is text instead of a linear scale.
	},
	"four_rod_bl": {
		"value": 1,
		"atypical" : true,
		"text" : false,
	},
	"four_rod_tr": {
		"value": 1,
		"atypical" : true,
		"text" : false,
	},
	"four_rod_tl": {
		"value": 1,
		"atypical" : true,
		"text" : false,
	},
	"srm_a_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_a_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	"srm_b_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_b_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	"srm_c_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_c_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	"srm_d_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_d_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	
	"srm_a_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_a_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	"srm_b_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_b_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	"srm_c_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_c_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	"srm_d_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_d_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	"aprm_temporary": {
		"node": $"Control Room Panels/Main Panel Center/Power/Label3D",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
}

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
	"cb_14-2": {
		"switch": null,
		"positions": {
			0: 45, #Trip
			1: 0, 
			2: -45, #Close
		},
		"position": 1,
		"momentary": false,
		"updated": false,
	},
	"cb_15-3": {
		"switch": null,
		"positions": {
			0: 45, #Trip
			1: 0, 
			2: -45, #Close
		},
		"position": 1,
		"momentary": false,
		"updated": false,
	},
	
	"cb_14-1": {
		"switch": null,
		"positions": {
			0: 45, #Trip
			1: 0, 
			2: -45, #Close
		},
		"position": 1,
		"momentary": false,
		"updated": false,
	},
	"cb_101-14": {
		"switch": null,
		"positions": {
			0: 45, #Trip
			1: 0, 
			2: -45, #Close
		},
		"position": 1,
		"momentary": false,
		"updated": false,
	},
	
	"cb_15-8": {
		"switch": null,
		"positions": {
			0: 45, #Trip
			1: 0, 
			2: -45, #Close
		},
		"position": 1,
		"momentary": false,
		"updated": false,
	},
	"cb_103-8": {
		"switch": null,
		"positions": {
			0: 45, #Trip
			1: 0, 
			2: -45, #Close
		},
		"position": 1,
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
	
	"SCRAM_RESET_A": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"SCRAM_RESET_B": {
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
	
	"ALARM_SILENCE_2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"ALARM_ACK_2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"ALARM_RESET_2": {
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
	
	"RMCS_INSERT_PB": {
		"switch": null,
		"state": false,
		"momentary": false,
		"updated": false,
	},
	"RMCS_WITHDRAW_PB": {
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
	"reactor_scram_a1_and_b1_loss": {
		"box": "Box1",
		"window": "1-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"1/2_scram_system_a": {
		"box": "Box1",
		"window": "3-4",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rpv_level_low_trip_a": {
		"box": "Box1",
		"window": "2-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rod_accumulator_trouble": {
		"box": "Box1",
		"window": "6-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rod_out_block": {
		"box": "Box1",
		"window": "2-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rod_drift": {
		"box": "Box1",
		"window": "5-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	#Ann A8
	"reactor_scram_a2_and_b2_loss": {
		"box": "Box2",
		"window": "1-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"1/2_scram_system_b": {
		"box": "Box2",
		"window": "3-4",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rpv_level_low_trip_b": {
		"box": "Box2",
		"window": "2-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
}

var alarm_groups = {
	"1" : {"F" : true, "S" : true}, # F - Fast S - Slow
	"2" : {"F" : true, "S" : true}, # F - Fast S - Slow
}

@onready var indicators = {
	"SCRAM_A1": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A1".get_material(),
	"SCRAM_A2": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A2".get_material(),
	"SCRAM_A3": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A3".get_material(),
	"SCRAM_A4": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A4".get_material(),
	"SCRAM_A5": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A5".get_material(),
	"SCRAM_A6": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A6".get_material(),
	
	"SCRAM_B1": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A1".get_material(),
	"SCRAM_B2": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A2".get_material(),
	"SCRAM_B3": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A3".get_material(),
	"SCRAM_B4": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A4".get_material(),
	"SCRAM_B5": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A5".get_material(),
	"SCRAM_B6": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A6".get_material(),
	
	"RMCS_WITHDRAW_BLOCK": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_WITHDRAW_BLOCK".get_material(),
	"RMCS_INSERT_BLOCK": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_INSERT_BLOCK".get_material(),
	
	"RMCS_WITHDRAW": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_WITHDRAW".get_material(),
	"RMCS_INSERT": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_INSERT".get_material(),
	"RMCS_SETTLE": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_SETTLE".get_material(),
	
	"cr_light_normal": null,
	"cr_light_emergency": null,
	
	"APRM_A_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/A/UPSCALE_INOP".get_material(),
	"APRM_B_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/B/UPSCALE_INOP".get_material(),
	"APRM_C_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/C/UPSCALE_INOP".get_material(),
	"APRM_D_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/D/UPSCALE_INOP".get_material(),
	"APRM_E_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/E/UPSCALE_INOP".get_material(),
	"APRM_F_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/F/UPSCALE_INOP".get_material(),
	
	"APRM_A_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/A/UPSCALE".get_material(),
	"APRM_B_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/B/UPSCALE".get_material(),
	"APRM_C_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/C/UPSCALE".get_material(),
	"APRM_D_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/D/UPSCALE".get_material(),
	"APRM_E_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/E/UPSCALE".get_material(),
	"APRM_F_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/F/UPSCALE".get_material(),

	"APRM_A_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/A/DOWNSCALE".get_material(),
	"APRM_B_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/B/DOWNSCALE".get_material(),
	"APRM_C_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/C/DOWNSCALE".get_material(),
	"APRM_D_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/D/DOWNSCALE".get_material(),
	"APRM_E_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/E/DOWNSCALE".get_material(),
	"APRM_F_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/F/DOWNSCALE".get_material(),
	
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

const remote_player_scene = preload("res://Assets/Scenes/Player/remote_player.tscn")

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
	get_tree().change_scene_to_file("res://Assets/Scenes/Lobby/lobby.tscn")
	set_process(false) # Stop processing.

func _ready(): # assume here that the scene was called by the lobby screen
	build_rod_select()
	var endpoint = "ws://%s/ws" % [globals.server_ip_requested_tojoin] # TODO: should token be generated on server-side?
	socket.connect_to_url(endpoint)

	for alarm in alarms:
		alarm = alarms[alarm]
		alarm["material"] = get_node("Annunciators/"+alarm["box"]+"/Windows/"+alarm["window"]+"/CSGBox3D").get_material()
	

	
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
							if gauges[gauge].atypical: continue
							if gauges[gauge].text:
								gauges[gauge].node.set_gauge_value(gauges[gauge].value)
							else:
								gauges[gauge].node.set_gauge_value(gauges[gauge].value, gauges[gauge].min_value, gauges[gauge].max_value)
					
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
							if "cr_light" in indicator:
								if indicator == "cr_light_normal":
									$LightNormal.visible = indicator_state
								if indicator == "cr_light_emergency":
									$LightEmergency.visible = indicator_state
								continue
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
						print("rod update")
							
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
					#request all the information for the client
					var err = socket.send_text(build_packet(client_packets.SYNCHRONIZE,"a")) #TODO: does it matter what text we send? can i use a different way?
