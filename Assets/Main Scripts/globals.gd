extends Node

var server_ip_requested_tojoin = null
var username_requested_tojoin = null
var connection_state = WebSocketPeer.STATE_CLOSED
var last_sent_x = 0
var last_sent_y = 0
var last_sent_z = 0
var disconnect_msg = ""

var renderer = null

var use_vr = false

var version = "alpha2025223"
