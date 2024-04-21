extends Node3D
var json = JSON.new()
var socket = WebSocketPeer.new()
const uuid_util = preload('res://addons/uuid/uuid.gd')

enum client_packets {
	LOGOUT = 2,
	SWITCH_PARAMETERS_UPDATE = 3,
}

enum server_packets {
	METER_PARAMETERS_UPDATE = 0,
	USER_LOGOUT = 1,
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
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false
	},
}

func build_packet(packet_id, data):
	return "{%s}|{%s}" % [str(packet_id), Marshalls.utf8_to_base64(data)]

func _ready():
	socket.connect_to_url("ws://192.168.0.112:7001/ws/%s" % [uuid_util.v4()]) # TODO: should token be generated on server-side?
	
func parse_b64(b64):
	# remove b'' from string
	b64 = b64.right(-2).left(-1)
	return Marshalls.base64_to_utf8(b64)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		# check if any switches have been turned
		for switch_name in switches:
			var switch = switches[switch_name]
			if switch.updated == true:
				pass
		
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
				
				
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

