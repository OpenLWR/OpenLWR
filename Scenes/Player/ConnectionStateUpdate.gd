extends Label

func _process(_delta):
	var state = "Connected"
	if globals.connection_state == WebSocketPeer.STATE_CLOSED:
		state = "Disconnected"
	elif globals.connection_state == WebSocketPeer.STATE_CONNECTING:
		state = "Connecting"
	
	self.text = str("State: " + state)
