extends Node3D
@onready var node_3d = $"/root/Node3D"

func format_rwm(num:int,no_extra:bool):
	var text = ""

	if num == -1:
		text = "-" #blank

	if text == "" and not no_extra:
		var rod_1 = str(num).substr(1,2)
		var rod_2 = str(num).substr(3,2)
			
		text = "%s - %s" % [rod_1,rod_2]
	
	if text == "" and no_extra:
		text = str(num)
		
	return text

func init():
	while true:
		await get_tree().create_timer(0.1).timeout

		var value = format_rwm(node_3d.gauges["rwm_insert_error_1"].value,false)
		$"Text/INSERT_ERR_1/Label".text = value
		
		value = format_rwm(node_3d.gauges["rwm_insert_error_2"].value,false)
		$"Text/INSERT_ERR_2/Label".text = value
		
		value = format_rwm(node_3d.gauges["rwm_withdraw_error"].value,false)
		$"Text/WITHDRAW_ERR/Label".text = value
		
		value = format_rwm(node_3d.gauges["rwm_group"].value,true)
		$"Text/GROUP/Label".text = value

func _ready():
	node_3d.init_scene_objects.connect(init)
	
