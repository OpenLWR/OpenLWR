extends Node3D
@onready var node_3d = $"/root/Node3D"

func format_position(pos:int):
	var text = ""
	var selected = false
	#Information for this is from Hope Creek.
	# Double Dash -- Odd numbered position reed switch closed.
	# Double X XX Two even reed switches closed, RMCS Data Fault Light will be lit.
	# Blank no even or odd position reed switch closed
	match abs(pos):
		60: #this is considered "- -".
			text = "- -"
		70: #Double X
			text = "X X"
		80: #Blank:
			text = " "
	
	if abs(pos) != pos: #if the value is negative, this is the selected rod
		selected = true

	pos = abs(pos)
	pos = pos - 1 #prevents divide by 0 errors by having an offset of one
	if text == "":
		var double_0_text = ""
		if pos <= 9:
			double_0_text = "0%s" % str(pos)
		else:
			double_0_text = str(pos)
			
		text = "%s %s" % [double_0_text.substr(0,1),double_0_text.substr(1,1)]
		
	return {"a" : text, "b" : selected}

func init():
	while true:
		await get_tree().create_timer(0.1).timeout
		
		var value = format_position(node_3d.gauges["four_rod_bl"].value)
		var text = value.a
		var selected = value.b
		$"BL/Pos".text = text
		if selected:
			$"BL/Pos".modulate = Color(1, 0.994, 0.705)
		else:
			$"BL/Pos".modulate = Color(255,255,255)
			
			
		value = format_position(node_3d.gauges["four_rod_br"].value)
		text = value.a
		selected = value.b
		$"BR/Pos".text = text
		if selected:
			$"BR/Pos".modulate = Color(1, 0.994, 0.705)
		else:
			$"BR/Pos".modulate = Color(255,255,255)
			
		value = format_position(node_3d.gauges["four_rod_tr"].value)
		text = value.a
		selected = value.b
		$"TR/Pos".text = text
		if selected:
			$"TR/Pos".modulate = Color(1, 0.994, 0.705)
		else:
			$"TR/Pos".modulate = Color(255,255,255)
			
		value = format_position(node_3d.gauges["four_rod_tl"].value)
		text = value.a
		selected = value.b
		$"TL/Pos".text = text
		if selected:
			$"TL/Pos".modulate = Color(1, 0.994, 0.705)
		else:
			$"TL/Pos".modulate = Color(255,255,255)

func _ready():
	node_3d.init_scene_objects.connect(init)
