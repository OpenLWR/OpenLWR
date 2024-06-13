extends Node3D

@onready var node_3d = $"/root/Node3D"
@onready var annunciator_state = node_3d.annunciator_state
var active_annunciator_on = false
var clear_annunciator_on = false
var internal_timer = 0

var alarm_node = "Alarm1/"

var ann_light = {}

func _ready():
	while true:
		active_annunciator_on = not active_annunciator_on
		internal_timer = internal_timer + 1
		if internal_timer % 3 == 0:
			clear_annunciator_on = not clear_annunciator_on
		if internal_timer > 11:
			internal_timer = 0
		var alarm_active = false
		var clear_alarm_active = false
		
		for box in ann_light:
			ann_light[box].lights_on = 0
			ann_light[box].colors = []
			#ann_light[box].avg_color = Color()
		
		
		for alarm in node_3d.alarms:
			alarm = node_3d.alarms[alarm]
			
			if alarm.box not in ann_light:
				ann_light[alarm.box] = {
					"lights_on" : 0,
					"colors" : [],
					"avg_color" : Color(),
				}
			
			if alarm.material == null:
				continue
			match alarm.state:
				annunciator_state.CLEAR:
					alarm.material.emission_enabled = false
				
				annunciator_state.ACTIVE:
					alarm.material.emission_enabled = active_annunciator_on
					alarm_active = true
				
				annunciator_state.ACKNOWLEDGED:
					alarm.material.emission_enabled = true
					
				annunciator_state.ACTIVE_CLEAR:
					alarm.material.emission_enabled = clear_annunciator_on
					clear_alarm_active = true	
					
			# TODO: allow clients to turn this off in settings as this probably has a pretty big performance impact
			# also disable when main lights on as it's not visible anyways
			if true:
				if alarm.material.emission_enabled == true:
					ann_light[alarm.box].lights_on += 1
						
					ann_light[alarm.box].colors.append(alarm.material.emission)
						
		
		for box in ann_light:
			var box_table = ann_light[box]
			box_table.avg_color = Color(0,0,0,1)
			for color in box_table.colors:
				box_table.avg_color += color
				
			if len(box_table.colors) != 0:
				box_table.avg_color = box_table.avg_color/len(box_table.colors)
				
			box_table.avg_color.a = 1
			
			print(box_table.avg_color)
			if box_table.lights_on > 0:
				get_node(box+"/Lighting").visible = true
				get_node(box+"/Lighting").light_energy = (box_table.lights_on/30)+0.003
				get_node(box+"/Lighting").light_color = box_table.avg_color
			else:
				get_node(box+"/Lighting").visible = false
			
		await get_tree().create_timer(0.1).timeout
	
