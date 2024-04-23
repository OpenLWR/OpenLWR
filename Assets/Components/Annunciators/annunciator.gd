extends Node3D

@onready var node_3d = $"/root/Node3D"
@onready var annunciator_state = node_3d.annunciator_state
var active_annunciator_on = false
var clear_annunciator_on = false
var internal_timer = 0

func _ready():
	while true:
		active_annunciator_on = not active_annunciator_on
		internal_timer = internal_timer + 1
		if internal_timer % 3 == 0:
			clear_annunciator_on = not clear_annunciator_on
		if internal_timer > 11:
			internal_timer = 0
		for alarm in node_3d.alarms:
			alarm = node_3d.alarms[alarm]
			if alarm.material == null:
				continue
			match alarm.state:
				annunciator_state.CLEAR:
					alarm.material.emission_enabled = false
				
				annunciator_state.ACTIVE:
					alarm.material.emission_enabled = active_annunciator_on
				
				annunciator_state.ACKNOWLEDGED:
					alarm.material.emission_enabled = true
					
				annunciator_state.ACTIVE_CLEAR:
					alarm.material.emission_enabled = clear_annunciator_on
				
		
		
		
		await get_tree().create_timer(0.1).timeout
	
