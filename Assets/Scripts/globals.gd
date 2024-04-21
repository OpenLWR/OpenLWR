extends Node

var server_ip_requested_tojoin = null
var username_requested_tojoin = null
var connection_state = WebSocketPeer.STATE_CLOSED

var renderer = null
