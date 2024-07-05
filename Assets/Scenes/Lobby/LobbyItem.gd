extends PanelContainer

@export var server_name: String
@export var server_ip: String

var response: Variant = null

@export var unselected: StyleBox
@export var selected: StyleBox

const STATUS_URL = "/status"

func _ready():
	$LobbyItem/Line1/Label.text = server_name
	$LobbyItem/Line2/Label3.text = server_ip
	add_theme_stylebox_override("panel", unselected)
	if $HTTPRequest.request("http://%s%s" % [server_ip, STATUS_URL]) != OK:
		ping_fail.emit()
	pass

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			grab_focus()
	pass

signal ping_complete()

func _on_ping_complete():
	var status = response["status"]
	var online = str(response.get("online", "???"))
	$LobbyItem/Line2/Label3.text = status
	$LobbyItem/Line1/Label2.text = "%s online" % online
	pass

signal ping_fail()

func _on_ping_fail():
	$LobbyItem/Line2/Label3.text = "[color=red]Unable to connect to server (skill issue)[/color]"
	$LobbyItem/Line1/Label2.text = "error"
	pass

func _on_focus_entered():
	add_theme_stylebox_override("panel", selected)
	pass

func _on_focus_exited():
	add_theme_stylebox_override("panel", unselected)
	pass


func _on_http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		ping_fail.emit()
		return
	print(body.get_string_from_utf8())
	response = JSON.parse_string(body.get_string_from_utf8())
	if response is Dictionary:
		ping_complete.emit()
	else:
		ping_fail.emit()
	pass # Replace with function body.
