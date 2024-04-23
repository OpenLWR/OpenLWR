extends Node3D
var json = JSON.new()
var socket = WebSocketPeer.new()

enum client_packets {
	SWITCH_PARAMETERS_UPDATE = 2,
}

enum server_packets {
	METER_PARAMETERS_UPDATE = 0,
	USER_LOGOUT = 1,
	SWITCH_PARAMETERS_UPDATE = 3,
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

enum annunciator_state {
	CLEAR = 0,
	ACTIVE = 1,
	ACKNOWLEDGED = 2,
	ACTIVE_CLEAR = 3,
}

var annunciators = {
	"test alarm": {
		"box": 1,
		"window": "A1",
		"state": annunciator_state.CLEAR,
		"color": "a", #TODO: how to set this to an actual color?
		"material": null,
	},
}

func build_packet(packet_id, data):
	return "%s|%s" % [str(packet_id), Marshalls.utf8_to_base64(data)]
	

func _ready(): # assume here that the scene was called by the lobby screen
	var endpoint = "ws://%s:7001/ws" % [globals.server_ip_requested_tojoin] # TODO: should token be generated on server-side?
	socket.connect_to_url(endpoint)
	
func parse_b64(b64):
	return Marshalls.base64_to_utf8(b64)

func _process(delta):
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
				
				
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		#kick to lobby screen
		get_tree().change_scene_to_file("res://lobby.tscn")
		set_process(false) # Stop processing.

