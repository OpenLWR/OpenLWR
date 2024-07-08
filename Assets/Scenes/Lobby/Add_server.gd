extends ConfirmationDialog

func _reset_line_edits():
	$VBoxContainer/Name/LineEdit.text = ""
	$VBoxContainer/Ip/LineEdit.text = ""
	pass

func _on_canceled():
	_reset_line_edits()
	pass # Replace with function body.


func _on_confirmed():
	$"../Panel/HSplitContainer/ServerList".add_server(
		$VBoxContainer/Ip/LineEdit.text, $VBoxContainer/Name/LineEdit.text)
	_reset_line_edits()
	hide()
	pass # Replace with function body.
