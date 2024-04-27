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

func set_rod_light_emission(rod_number,light,state):
	var fcd_light = get_node(str(rod_number)+"/"+(fcd_enums[light]))
	fcd_light.get_material().emission_enabled = state

func _ready():
	while node_3d.rod_information == null:
		await get_tree().create_timer(0.1).timeout #just wait around for it to come in
		
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
			# TODO: check if 18-59 actually needs this offset (or whatever the first rod in the dict is)
			if rod_info["accum_trouble_acknowledged"] == false:
				if rod_info["accum_trouble"] and cycles >= 0: #(rod_number == "18-59" or cycles >= 0):
					set_rod_light_emission(rod_number, "ACCUM", cycles <= 1 and not rpis_inop)
				else:
					set_rod_light_emission(rod_number, "ACCUM", false)
			else:
				set_rod_light_emission(rod_number, "ACCUM", rod_info["cr_accum_trouble"] and not rpis_inop)
			if cycles >= 3:
				cycles = -1
			
		cycles += 1
		#TODO: LPRMs
		#for lprm_number in node_3d.local_power_range_monitors:
		#	for detector in node_3d.local_power_range_monitors[lprm_number]:
		#		node_3d.local_power_range_monitors[lprm_number][detector]["full_core_display_downscale_light"].emission_enabled = true if node_3d.local_power_range_monitors[lprm_number][detector]["power"] < 3 else false
		#		node_3d.local_power_range_monitors[lprm_number][detector]["full_core_display_upscale_light"].emission_enabled = true if node_3d.local_power_range_monitors[lprm_number][detector]["power"] > node_3d.local_power_range_monitors[lprm_number][detector]["upscale_setpoint"] else false

func _process(delta):
	pass
