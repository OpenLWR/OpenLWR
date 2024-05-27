extends Node3D
@onready var node_3d = $"/root/Node3D"

var thread
var cycles = 0
var insertion
var rpis_inop = false #TODO: make these replicate from server
var fcd_inop = false #TODO: make these replicate from server

var fcd_enums = {
	"ACCUM" : "ACCUM_SCRAM_IND/ACCUM",
	"SCRAM" : "ACCUM_SCRAM_IND/SCRAM",
	"DRIFT" : "ROD_DRIFT_IND/DRIFT",
	"SELECT" : "ROD_DRIFT_IND/ROD",
	"FULL_IN" : "FULL_IN_OUT_IND/FULL IN",
	"FULL_OUT" : "FULL_IN_OUT_IND/FULL OUT",
}

var fcd_lights = {
	"02-17" : {
		"ACCUM" : null,
		"SCRAM" : null,
		"DRIFT" : null,
		"SELECT" : null,
		"FULL_IN" : null,
		"FULL_OUT" : null,
	}
}

func set_rod_light_emission(rod_number,light,state):
	var fcd_light = fcd_lights[rod_number][light]
	fcd_light.emission_enabled = state and (not fcd_inop)
	
func generate_rod_material():
	for rod_number in node_3d.rod_information:
		fcd_lights[rod_number] = {}
		for light in fcd_enums:
			var fcd_light = get_node(str(rod_number)+"/"+(fcd_enums[light]))
			fcd_lights[rod_number][light] = fcd_light.get_material()
	return true

func _ready():
	while node_3d.rod_information == null or node_3d.rod_information == {}:
		await get_tree().create_timer(0.1).timeout #just wait around for it to come in
	
	generate_rod_material()
	
	while true:
		await get_tree().create_timer(0.1).timeout
		for rod_number in node_3d.rod_information:
			var rod_info = node_3d.rod_information[rod_number]
			insertion = rod_info.insertion
			set_rod_light_emission(rod_number, "FULL_IN", insertion == 0 and not rpis_inop)
			set_rod_light_emission(rod_number, "FULL_OUT", insertion == 48 and not rpis_inop)
			set_rod_light_emission(rod_number, "SCRAM", rod_info["scram"] and not rpis_inop)
			set_rod_light_emission(rod_number, "DRIFT", rod_info["drift_alarm"] and not rpis_inop)
			set_rod_light_emission(rod_number, "SELECT", rod_info["select"] and not rpis_inop)
			
			# 18-59 has a slight offset to avoid it appearing desynced from the rest of the lights
			if rod_info["accum_trouble_acknowledged"] == false:
				if rod_info["accum_trouble"] and (cycles <= 1 or (rod_number == "18-59" and (cycles == 0 or cycles == 5))) :
					set_rod_light_emission(rod_number, "ACCUM", not rpis_inop)
				else:
					set_rod_light_emission(rod_number, "ACCUM", false)
			else:
				set_rod_light_emission(rod_number, "ACCUM", rod_info["accum_trouble"] and not rpis_inop)
			if cycles >= 5:
				cycles = -1
			
		cycles += 1
		#TODO: LPRMs
		#for lprm_number in node_3d.local_power_range_monitors:
		#	for detector in node_3d.local_power_range_monitors[lprm_number]:
		#		node_3d.local_power_range_monitors[lprm_number][detector]["full_core_display_downscale_light"].emission_enabled = true if node_3d.local_power_range_monitors[lprm_number][detector]["power"] < 3 else false
		#		node_3d.local_power_range_monitors[lprm_number][detector]["full_core_display_upscale_light"].emission_enabled = true if node_3d.local_power_range_monitors[lprm_number][detector]["power"] > node_3d.local_power_range_monitors[lprm_number][detector]["upscale_setpoint"] else false

func _process(delta):
	pass
