extends Node3D
var json = JSON.new()
var socket = WebSocketPeer.new()

enum client_packets {
	SWITCH_PARAMETERS_UPDATE = 2,
	BUTTON_PARAMETERS_UPDATE = 6,
	PLAYER_POSITION_PARAMETERS_UPDATE = 9,
	ROD_SELECT_UPDATE = 11,
	USER_LOGIN = 12,
	SYNCHRONIZE = 14,
	CHAT = 15,
	RCON = 19,
	RECORDER = 21,
}

enum server_packets {
	METER_PARAMETERS_UPDATE = 0,
	USER_LOGOUT = 1,
	SWITCH_PARAMETERS_UPDATE = 3,
	INDICATOR_PARAMETERS_UPDATE = 4,
	ALARM_PARAMETERS_UPDATE = 5,
	BUTTON_PARAMETERS_UPDATE = 7,
	PLAYER_POSITION_PARAMETERS_UPDATE = 8,
	ROD_POSITION_PARAMETERS_UPDATE = 10,
	USER_LOGIN_ACK = 13,
	CHAT = 16,
	DOWNLOAD_DATA = 17,
	KICK = 18,
	RECORDER = 20,
}

signal chat_message(message)

@onready var gauges = {
	"four_rod_br": {
		"value": 1,
		"atypical" : true, #The min/maxes dont apply. This is simply used for receiving a value.
		"text" : false, #Is handled differently than regular gauges. Is text instead of a linear scale.
	},
	"four_rod_bl": {
		"value": 1,
		"atypical" : true,
		"text" : false,
	},
	"four_rod_tr": {
		"value": 1,
		"atypical" : true,
		"text" : false,
	},
	"four_rod_tl": {
		"value": 1,
		"atypical" : true,
		"text" : false,
	},
	"srm_a_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_a_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	"srm_b_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_b_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	"srm_c_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_c_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	"srm_d_counts": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_d_counts",
		"value": 0,
		"min_value": -2.33,
		"max_value": 14,
		"atypical" : false,
		"text" : false,
	},
	
	"srm_a_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_a_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	"srm_b_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_b_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	"srm_c_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_c_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	"srm_d_period": {
		"node": $"Control Room Panels/Main Panel Center/Controls/srm_d_period",
		"value": 0,
		"min_value": -0.009998,
		"max_value": 0.09930,
		"atypical" : false,
		"text" : false,
	},
	
	"hpcs_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/HPCS/hpcs_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 7000,
		"atypical" : false,
		"text" : false,
	},
	"hpcs_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/HPCS/hpcs_press",
		"value": 0,
		"min_value": 0,
		"max_value": 1500,
		"atypical" : false,
		"text" : false,
	},

	"rhr_b_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RHR B/rhr_b_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 10000,
		"atypical" : false,
		"text" : false,
	},
	"rhr_b_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RHR B/rhr_b_press",
		"value": 0,
		"min_value": 0,
		"max_value": 500,
		"atypical" : false,
		"text" : false,
	},
	
	"rhr_c_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RHR C/rhr_c_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 10000,
		"atypical" : false,
		"text" : false,
	},
	"rhr_c_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RHR C/rhr_c_press",
		"value": 0,
		"min_value": 0,
		"max_value": 500,
		"atypical" : false,
		"text" : false,
	},
	
	"rpv_level_recorder_1": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/rpv_level/Sprite3D/SubViewport/Node2D/1_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"rpv_pressure_recorder_1": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/rpv_level/Sprite3D/SubViewport/Node2D/2_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	
	"irm_a_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS1/Sprite3D/SubViewport/Node2D/1_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"aprm_a_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS1/Sprite3D/SubViewport/Node2D/2_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"irm_c_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS1/Sprite3D/SubViewport/Node2D/3_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"aprm_c_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS1/Sprite3D/SubViewport/Node2D/4_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	
	"irm_e_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS2/Sprite3D/SubViewport/Node2D/1_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"aprm_e_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS2/Sprite3D/SubViewport/Node2D/2_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"irm_g_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS2/Sprite3D/SubViewport/Node2D/3_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"rbm_a_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS2/Sprite3D/SubViewport/Node2D/4_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	
	
	"irm_b_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS3/Sprite3D/SubViewport/Node2D/1_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"aprm_b_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS3/Sprite3D/SubViewport/Node2D/2_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"irm_d_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS3/Sprite3D/SubViewport/Node2D/3_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"aprm_d_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS3/Sprite3D/SubViewport/Node2D/4_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	
	"irm_f_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS4/Sprite3D/SubViewport/Node2D/1_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"aprm_f_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS4/Sprite3D/SubViewport/Node2D/2_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"irm_h_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS4/Sprite3D/SubViewport/Node2D/3_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	"rbm_b_recorder": {
		"node": $"Control Room Panels/Main Panel Center/Controls/NMS4/Sprite3D/SubViewport/Node2D/4_VALUE",
		"value": 1,
		"atypical" : false,
		"text" : true,
	},
	
	"rcic_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RCIC/rcic_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 700,
		"atypical" : false,
		"text" : false,
	},
	
	"rcic_rpm": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RCIC/rcic_rpm",
		"value": 0,
		"min_value": 0,
		"max_value": 7000,
		"atypical" : false,
		"text" : false,
	},
	
	"rcic_supply_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RCIC/rcic_supply_press",
		"value": 0,
		"min_value": 0,
		"max_value": 1200,
		"atypical" : false,
		"text" : false,
	},
	"rcic_exhaust_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RCIC/rcic_exhaust_press",
		"value": 0,
		"min_value": 0,
		"max_value": 50,
		"atypical" : false,
		"text" : false,
	},
	
	"rcic_pump_disch_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RCIC/rcic_pump_disch_press",
		"value": 0,
		"min_value": 0,
		"max_value": 1300,
		"atypical" : false,
		"text" : false,
	},
	"rcic_pump_suct_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RCIC/rcic_pump_suct_press",
		"value": 0,
		"min_value": 0,
		"max_value": 100,
		"atypical" : false,
		"text" : false,
	},
	
	"lpcs_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/LPCS/lpcs_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 10000,
		"atypical" : false,
		"text" : false,
	},
	"lpcs_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/LPCS/lpcs_press",
		"value": 0,
		"min_value": 0,
		"max_value": 500,
		"atypical" : false,
		"text" : false,
	},
	
	"rhr_a_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RHR A/rhr_a_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 10000,
		"atypical" : false,
		"text" : false,
	},
	"rhr_a_press": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RHR A/rhr_a_press",
		"value": 0,
		"min_value": 0,
		"max_value": 500,
		"atypical" : false,
		"text" : false,
	},
	
	"bus_4_voltage": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/HPCS/bus_4_voltage",
		"value": 0,
		"min_value": 0,
		"max_value": 6000,
		"atypical" : false,
		"text" : false,
	},
	"main_generator_sync": {
		"node": $"main_generator_sync",
		"value": 0,
		"min_value": 0,
		"max_value": 0,
		"atypical" : false,
		"text" : false,
	},
	"div_1_sync": {
		"node": $"div_1_sync",
		"value": 0,
		"min_value": 0,
		"max_value": 0,
		"atypical" : false,
		"text" : false,
	},
	"div_2_sync": {
		"node": $"div_2_sync",
		"value": 0,
		"min_value": 0,
		"max_value": 0,
		"atypical" : false,
		"text" : false,
	},
	
	#Reactor Recirculation
	
	#RR B
	
	"rrc_p_1b_volts": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1b_volts",
		"value": 0,
		"min_value": 0,
		"max_value": 8000,
		"atypical" : false,
		"text" : false,
	},
	"rrc_p_1b_amps": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1b_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 1000,
		"atypical" : false,
		"text" : false,
	},
	
	"rrc_p_1b_freq": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1b_freq",
		"value": 0,
		"min_value": 0,
		"max_value": 70,
		"atypical" : false,
		"text" : false,
	},
	"rrc_p_1b_speed": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1b_speed",
		"value": 0,
		"min_value": 0,
		"max_value": 2000,
		"atypical" : false,
		"text" : false,
	},
	
	"station_1b_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1b/station_1b_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 60000,
		"atypical" : false,
		"text" : false,
	},
	"station_1b_bias": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1b/station_1b_bias",
		"value": 0,
		"min_value": -10,
		"max_value": 10,
		"atypical" : false,
		"text" : false,
	},
	"station_1b_demand": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1b/station_1b_demand",
		"value": 0,
		"min_value": 0,
		"max_value": 70,
		"atypical" : false,
		"text" : false,
	},
	"station_1b_actual": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1b/station_1b_actual",
		"value": 0,
		"min_value": 0,
		"max_value": 70,
		"atypical" : false,
		"text" : false,
	},
	
	#RR A
	
	"rrc_p_1a_volts": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1a_volts",
		"value": 0,
		"min_value": 0,
		"max_value": 8000,
		"atypical" : false,
		"text" : false,
	},
	"rrc_p_1a_amps": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1a_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 1000,
		"atypical" : false,
		"text" : false,
	},
	
	"rrc_p_1a_freq": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1a_freq",
		"value": 0,
		"min_value": 0,
		"max_value": 70,
		"atypical" : false,
		"text" : false,
	},
	"rrc_p_1a_speed": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/rrc_p_1a_speed",
		"value": 0,
		"min_value": 0,
		"max_value": 2000,
		"atypical" : false,
		"text" : false,
	},
	
	"station_1a_flow": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1a/station_1a_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 60000,
		"atypical" : false,
		"text" : false,
	},
	"station_1a_bias": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1a/station_1a_bias",
		"value": 0,
		"min_value": -10,
		"max_value": 10,
		"atypical" : false,
		"text" : false,
	},
	"station_1a_demand": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1a/station_1a_demand",
		"value": 0,
		"min_value": 0,
		"max_value": 70,
		"atypical" : false,
		"text" : false,
	},
	"station_1a_actual": {
		"node": $"Control Room Panels/Main Panel Left Side/Controls/RRC/station_1a/station_1a_actual",
		"value": 0,
		"min_value": 0,
		"max_value": 70,
		"atypical" : false,
		"text" : false,
	},
	
	"rwm_group": {
		"value": -1,
		"atypical" : true,
		"text" : false,
	},
	"rwm_insert_error_1": {
		"value": -1,
		"atypical" : true,
		"text" : false,
	},
	"rwm_insert_error_2": {
		"value": -1,
		"atypical" : true,
		"text" : false,
	},
	"rwm_withdraw_error": {
		"value": -1,
		"atypical" : true,
		"text" : false,
	},
	
	"mt_rpm": {
		"node": $"Control Room Panels/Main Panel Center/Controls/mt_rpm",
		"value": 0,
		"min_value": 0,
		"max_value": 2200,
		"atypical" : false,
		"text" : false,
	},
	
	#condensate
	"cond_booster_discharge_press": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_booster_discharge_press",
		"value": 0,
		"min_value": 0,
		"max_value": 1000,
		"atypical" : false,
		"text" : false,
	},
	"cond_booster_discharge_temp": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_booster_discharge_temp",
		"value": 0,
		"min_value": 0,
		"max_value": 200,
		"atypical" : false,
		"text" : false,
	},
	"cond_p_2a_amps": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_p_2a_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 600,
		"atypical" : false,
		"text" : false,
	},
	"cond_p_2b_amps": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_p_2b_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 600,
		"atypical" : false,
		"text" : false,
	},
	"cond_p_2c_amps": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_p_2c_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 600,
		"atypical" : false,
		"text" : false,
	},
	
	"cond_discharge_press": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_discharge_press",
		"value": 0,
		"min_value": 0,
		"max_value": 1000,
		"atypical" : false,
		"text" : false,
	},
	"cond_discharge_temp": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_discharge_temp",
		"value": 0,
		"min_value": 0,
		"max_value": 200,
		"atypical" : false,
		"text" : false,
	},
	"cond_p_1a_amps": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_p_1a_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 600,
		"atypical" : false,
		"text" : false,
	},
	"cond_p_1b_amps": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_p_1b_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 600,
		"atypical" : false,
		"text" : false,
	},
	"cond_p_1c_amps": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/Condensate/cond_p_1c_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 600,
		"atypical" : false,
		"text" : false,
	},
	
	"rft_dt_1a_rpm": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/RFW/rft_dt_1a_rpm",
		"value": 0,
		"min_value": 0,
		"max_value": 6000,
		"atypical" : false,
		"text" : false,
	},
	"rft_dt_1b_rpm": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/RFW/rft_dt_1b_rpm",
		"value": 0,
		"min_value": 0,
		"max_value": 6000,
		"atypical" : false,
		"text" : false,
	},
	
	"rfw_rpv_inlet_pressure": {
		"node": $"Control Room Panels/Main Panel Right Side/Controls/RFW/rfw_rpv_inlet_pressure",
		"value": 0,
		"min_value": 0,
		"max_value": 1600,
		"atypical" : false,
		"text" : false,
	},
	
	"crd_p_1a_amps": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/crd_p_1a_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 100,
		"atypical" : false,
		"text" : false,
	},
	"crd_p_1b_amps": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/crd_p_1b_amps",
		"value": 0,
		"min_value": 0,
		"max_value": 100,
		"atypical" : false,
		"text" : false,
	},
	
	"charge_header_pressure": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/charge_header_pressure",
		"value": 0,
		"min_value": 0,
		"max_value": 2000,
		"atypical" : false,
		"text" : false,
	},
	"drive_header_flow": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/drive_header_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 50,
		"atypical" : false,
		"text" : false,
	},
	"cooling_header_flow": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/cooling_header_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 80,
		"atypical" : false,
		"text" : false,
	},
	
	"drive_header_dp": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/drive_header_dp",
		"value": 0,
		"min_value": -500,
		"max_value": 500,
		"atypical" : false,
		"text" : false,
	},
	"cooling_header_dp": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/cooling_header_dp",
		"value": 0,
		"min_value": -500,
		"max_value": 500,
		"atypical" : false,
		"text" : false,
	},
	
	"crd_system_flow": {
		"node": $"Control Room Panels/Main Panel Center/Controls/CRD/crd_system_flow",
		"value": 0,
		"min_value": 0,
		"max_value": 300,
		"atypical" : false,
		"text" : false,
	},
}

var alarms = {}

var switches = {}

var buttons = {}


enum annunciator_state {
	CLEAR = 0,
	ACTIVE = 1,
	ACKNOWLEDGED = 2,
	ACTIVE_CLEAR = 3,
}

var alarm_groups = {
	"1" : {"F" : true, "S" : true}, # F - Fast S - Slow
	"2" : {"F" : true, "S" : true}, # F - Fast S - Slow
	"3" : {"F" : true, "S" : true}, # F - Fast S - Slow
	"4" : {"F" : true, "S" : true}, # F - Fast S - Slow
	"5" : {"F" : true, "S" : true}, # F - Fast S - Slow
}

@onready var indicators = {
	"SCRAM_A1": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A1",
	"SCRAM_A2": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A2",
	"SCRAM_A3": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A3",
	"SCRAM_A4": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A4",
	"SCRAM_A5": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A5",
	"SCRAM_A6": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_A/A6",
	
	"SCRAM_B1": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A1",
	"SCRAM_B2": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A2",
	"SCRAM_B3": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A3",
	"SCRAM_B4": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A4",
	"SCRAM_B5": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A5",
	"SCRAM_B6": $"Control Room Panels/Main Panel Center/Controls/SCRAM_LOGIC_B/A6",
	
	"RMCS_WITHDRAW_BLOCK": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_WITHDRAW_BLOCK",
	"RMCS_INSERT_BLOCK": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_INSERT_BLOCK",
	"RMCS_SELECT_BLOCK": $"Rod Select Panel/Panel 1/Lights and buttons/SelectBlock",
	
	"RMCS_WITHDRAW": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_WITHDRAW",
	"RMCS_CONT_WITHDRAW": $"Rod Select Panel/Panel 1/Lights and buttons/RMCS_CONT_WITHDRAW",
	"RMCS_INSERT": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_INSERT",
	"RMCS_SETTLE": $"Rod Select Panel/Panel 2/Lights and buttons/RMCS_SETTLE",
	
	"cr_light_normal_1": null,
	"cr_light_normal_2": null,
	"cr_light_normal_3": null,
	"cr_light_normal_4": null,
	"cr_light_emergency": null,
	
	"APRM_A_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/A/UPSCALE_INOP",
	"APRM_B_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/B/UPSCALE_INOP",
	"APRM_C_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/C/UPSCALE_INOP",
	"APRM_D_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/D/UPSCALE_INOP",
	"APRM_E_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/E/UPSCALE_INOP",
	"APRM_F_UPSCALE_TRIP_OR_INOP": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/F/UPSCALE_INOP",
	
	"APRM_A_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/A/UPSCALE",
	"APRM_B_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/B/UPSCALE",
	"APRM_C_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/C/UPSCALE",
	"APRM_D_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/D/UPSCALE",
	"APRM_E_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/E/UPSCALE",
	"APRM_F_UPSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/F/UPSCALE",

	"APRM_A_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/A/DOWNSCALE",
	"APRM_B_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/B/DOWNSCALE",
	"APRM_C_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/C/DOWNSCALE",
	"APRM_D_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/D/DOWNSCALE",
	"APRM_E_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/E/DOWNSCALE",
	"APRM_F_DOWNSCALE": $"Control Room Panels/Main Panel Center/Controls/APRM_STATUS/F/DOWNSCALE",
	
	"hpcs_init": $"Control Room Panels/Main Panel Left Side/Controls/HPCS/hpcs_active/seal_in",
	"hpcs_l8": $"Control Room Panels/Main Panel Left Side/Controls/HPCS/hpcs_l8/seal_in",
	
	#IRM/SRM Positioner
	
	#select and indications
	
	"SELECT_SRM_A": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_SRM_A",
	"SRM_A_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_A_POS/IN",
	"SRM_A_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_A_POS/OUT",
	"SRM_A_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_A_POS/PERMIT",

	"SELECT_SRM_B": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_SRM_B",
	"SRM_B_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_B_POS/IN",
	"SRM_B_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_B_POS/OUT",
	"SRM_B_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_B_POS/PERMIT",

	"SELECT_SRM_C": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_SRM_C",
	"SRM_C_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_C_POS/IN",
	"SRM_C_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_C_POS/OUT",
	"SRM_C_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_C_POS/PERMIT",

	"SELECT_SRM_D": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_SRM_D",
	"SRM_D_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_D_POS/IN",
	"SRM_D_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_D_POS/OUT",
	"SRM_D_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SRM_D_POS/PERMIT",
	
	"SELECT_IRM_A": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_A",
	"IRM_A_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_A_POS/IN",
	"IRM_A_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_A_POS/OUT",
	"IRM_A_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_A_POS/PERMIT",

	"SELECT_IRM_B": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_B",
	"IRM_B_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_B_POS/IN",
	"IRM_B_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_B_POS/OUT",
	"IRM_B_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_B_POS/PERMIT",

	"SELECT_IRM_C": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_C",
	"IRM_C_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_C_POS/IN",
	"IRM_C_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_C_POS/OUT",
	"IRM_C_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_C_POS/PERMIT",

	"SELECT_IRM_D": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_D",
	"IRM_D_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_D_POS/IN",
	"IRM_D_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_D_POS/OUT",
	"IRM_D_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_D_POS/PERMIT",

	"SELECT_IRM_E": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_E",
	"IRM_E_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_E_POS/IN",
	"IRM_E_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_E_POS/OUT",
	"IRM_E_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_E_POS/PERMIT",

	"SELECT_IRM_F": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_F",
	"IRM_F_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_F_POS/IN",
	"IRM_F_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_F_POS/OUT",
	"IRM_F_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_F_POS/PERMIT",

	"SELECT_IRM_G": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_G",
	"IRM_G_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_G_POS/IN",
	"IRM_G_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_G_POS/OUT",
	"IRM_G_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_G_POS/PERMIT",

	"SELECT_IRM_H": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/SELECT_IRM_H",
	"IRM_H_POS_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_H_POS/IN",
	"IRM_H_POS_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_H_POS/OUT",
	"IRM_H_RETRACT_PERMIT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/IRM_H_POS/PERMIT",
	
	#Drive control lights for IRM/SRM Positoner
	
	"DET_DRIVE_IN": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/DET_DRIVE_IN",
	"DET_DRIVE_OUT": $"Control Room Panels/Main Panel Center/SRM_IRM POSITIONER/DET_DRIVE_OUT",
	
	"FCD_OPERATE": null,
	"CHART_RECORDERS_OPERATE": null,
	
	"rcic_init": $"Control Room Panels/Main Panel Left Side/Controls/RCIC/rcic_initiation/sealed_in",
	
	"lpcs_init": $"Control Room Panels/Main Panel Left Side/Controls/LPCS/lpcs_init/seal_in",
	"rhr_cb_init": $"Control Room Panels/Main Panel Left Side/Controls/RHR C/rhr_cb_init/seal_in",
	
	"rwm_insert_block": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/INSERT_BLOCK",
	"rwm_withdraw_block": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/WITHDRAW_BLOCK",
	"rwm_select_error": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/SELECT_ERROR",
	"rwm_manual": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/MANUAL",
	"rwm_auto": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/AUTO",
	
	"rwm_seq": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/SEQ",
	"rwm_init": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/rwm_seq",
	"rwm_lpsp": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/LPSP",
	"rwm_lpap": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/LPAP",
	"rwm_test": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/rwm_test",
	"rwm_select": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/SELECT",
	"rwm_diag": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/rwm_diag",
	"rwm_rwm": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/RWM",
	"rwm_comp": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/COMP",
	"rwm_prog": $"Control Room Panels/Main Panel Center/Controls/Rod Worth Minimizer/Indicators/rwm_rwm_comp_prog",
	
	"ehc_closed": $"Control Room Panels/Main Panel Right Side/Controls/EHC/SPEED/ehc_closed",
	"ehc_100": $"Control Room Panels/Main Panel Right Side/Controls/EHC/SPEED/ehc_100",
	"ehc_500": $"Control Room Panels/Main Panel Right Side/Controls/EHC/SPEED/ehc_500",
	"ehc_1500": $"Control Room Panels/Main Panel Right Side/Controls/EHC/SPEED/ehc_1500",
	"ehc_1800": $"Control Room Panels/Main Panel Right Side/Controls/EHC/SPEED/ehc_1800",
	"ehc_overspeed": $"Control Room Panels/Main Panel Right Side/Controls/EHC/SPEED/ehc_overspeed",
	
	"ehc_slow": $"Control Room Panels/Main Panel Right Side/Controls/EHC/START UP RATE/ehc_slow",
	"ehc_med": $"Control Room Panels/Main Panel Right Side/Controls/EHC/START UP RATE/ehc_med",
	"ehc_fast": $"Control Room Panels/Main Panel Right Side/Controls/EHC/START UP RATE/ehc_fast",
	
	"ehc_line_speed_off": $"Control Room Panels/Main Panel Right Side/Controls/EHC/LINE SPEED MATCHER/ehc_line_speed_off",
	"ehc_line_speed_selected": $"Control Room Panels/Main Panel Right Side/Controls/EHC/LINE SPEED MATCHER/ehc_line_speed_selected",
	"ehc_line_speed_operating": $"Control Room Panels/Main Panel Right Side/Controls/EHC/LINE SPEED MATCHER/ehc_line_speed_operating",
	
	"mt_tripped": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/mt_tripped",
	"mt_reset": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/mt_reset",
	
	#mech trip test
	"mech_trip_normal": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/MECH TRIP TEST/mech_trip_normal",
	"mech_trip_lockout": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/MECH TRIP TEST/mech_trip_lockout",
	"mech_trip_oiltrip": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/MECH TRIP TEST/mech_trip_oiltrip",
	"mech_trip_reset_pb": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/MECH TRIP TEST/mech_trip_reset_pb",
	
	#mech trip
	"mech_trip_tripped": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/MECH TRIP/mech_trip_tripped",
	"mech_trip_resetting": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/MECH TRIP/mech_trip_resetting",
	"mech_trip_reset": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/MECH TRIP/mech_trip_reset",
	
	#condenser vacuum trip
	"vacuum_tripped": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/COND VAC/vacuum_tripped",
	"vacuum_normal": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/COND VAC/vacuum_normal",
	"vacuum_reset": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/COND VAC/vacuum_reset",
	"vacuum_low": $"Control Room Panels/Main Panel Right Side/Controls/EHC/TRIP/COND VAC/vacuum_low",
}

var rod_information = {}

var recorders = {}

@onready var players = {
	#"1":{ #key is userid, for now its username
	#	"position" : {"x" : 0, "y" : 0, "z" : 0,}, # Can we use a Vector3 here?
	#	"username" : "john",
	#	"object" : null, #player object to manipulate, 
	#}
}

signal init_scene_objects

var tables_received = []

var selected_rod = null
@onready var tween = get_tree().create_tween()

var connection_ready = false
var connection_packet_sent = false
var connection_timeout = 0

var sent_messages: PackedStringArray = PackedStringArray()

const remote_player_scene = preload("res://Assets/Scenes/Player/remote_player.tscn")
const vr_player_scene = preload("res://Assets/Scenes/Player/vr_player.tscn")
const pc_player_scene = preload("res://Assets/Scenes/Player/player.tscn")

func build_packet(packet_id, data):
	return "%s|%s" % [str(packet_id), Marshalls.utf8_to_base64(data)]

func build_rod_select():
	print("s")
	#for rod in rod_information:
		#var button = buttons["select_%s" % rod]

func _disconnect():
	socket.close()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_disconnect()

func disconnected(socket):
	var code = socket.get_close_code()
	var reason = socket.get_close_reason()
	print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
	#kick to lobby screen
	get_tree().change_scene_to_file("res://Assets/Scenes/Lobby/new_lobby.tscn")
	set_process(false) # Stop processing.

func init_scene():
	
	init_scene_objects.emit()
	
	if globals.use_vr:
		self.remove_child($"Player")
		var NewVRPlayer = vr_player_scene.instantiate()
		NewVRPlayer.name = "Player"
		self.add_child(NewVRPlayer)
		
	for indicator_name in indicators:
		var indicator = indicators[indicator_name]
		
		if indicator == null:
			continue
			
		var indicator_material = indicator.get_material().duplicate()
		indicator.material = indicator_material
		indicators[indicator_name] = indicator_material

	for alarm in alarms:
		alarm = alarms[alarm]
		var alarm_material = get_node("Annunciators/"+alarm["box"]+"/Windows/"+alarm["window"]+"/CSGBox3D").get_material().duplicate()
		get_node("Annunciators/"+alarm["box"]+"/Windows/"+alarm["window"]+"/CSGBox3D").material = alarm_material
		alarm["material"] = alarm_material
		
	build_rod_select()

func _ready(): # assume here that the scene was called by the lobby screen
	var endpoint = "ws://%s/ws" % [globals.server_ip_requested_tojoin] # TODO: should token be generated on server-side?
	socket.connect_to_url(endpoint)
	
var synchronized = false
var info_got = 0
	
func parse_b64(b64):
	return Marshalls.base64_to_utf8(b64)

@onready var config = ConfigFile.new()

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	globals.connection_state = state
	if connection_ready:
		if state == WebSocketPeer.STATE_OPEN:
			# we have to recieve first or weird things happen
			
			# recieve packets
			while socket.get_available_packet_count():
				var packet = socket.get_packet().get_string_from_utf8().split("|")
				var packet_id = int(packet[0])
				var packet_data = parse_b64(packet[1])
				match packet_id:
					server_packets.METER_PARAMETERS_UPDATE:
						# data: a dict of all indicator values, json
						packet_data = json.parse_string(packet_data)
						for gauge in packet_data:
							var value = packet_data[gauge]
							gauges[gauge].value = value
							if gauges[gauge].atypical: continue
							if gauges[gauge].text:
								gauges[gauge].node.set_gauge_value(gauges[gauge].value)
							else:
								gauges[gauge].node.set_gauge_value(gauges[gauge].value, gauges[gauge].min_value, gauges[gauge].max_value)
					
					server_packets.USER_LOGOUT:
						# data: the username of the person who logged out, string
						print("User %s logged out." % [packet_data])
						get_node(packet_data).queue_free() #deletes the remote player instance
						players.erase(packet_data) #removes the player's info from the player table
						
						
					server_packets.SWITCH_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						
						for switch in packet_data:
							var data = packet_data[switch]
							if switches[switch].updated == true: #if we have a update to this, we have to ignore what the server wants
								continue
							if switches[switch].switch != null:
								switches[switch].flag = data.flag
								switches[switch].switch.switch_position_change(data.position)
								
							for light_name in switches[switch].lights:
								var light = switches[switch].lights[light_name]
								state = data.lights[light_name]
								light.emission_enabled = state
					
					server_packets.INDICATOR_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for indicator in packet_data:
							var indicator_state = packet_data[indicator]
							if "cr_light" in indicator:
								if indicator == "cr_light_normal_1":
									$LightNormal_1.visible = indicator_state
								if indicator == "cr_light_normal_2":
									$LightNormal_2.visible = indicator_state
								if indicator == "cr_light_normal_3":
									$LightNormal_3.visible = indicator_state
								if indicator == "cr_light_normal_4":
									$LightNormal_4.visible = indicator_state
								if indicator == "cr_light_emergency":
									$LightEmergency.visible = indicator_state
								continue
							if "OPERATE" in indicator:
								if indicator == "FCD_OPERATE":
									$"Control Room Panels/Main Panel Center/Full Core Display/full core display lights".fcd_inop = not indicator_state
								continue
							indicators[indicator].emission_enabled = indicator_state
							
					server_packets.ALARM_PARAMETERS_UPDATE:
						packet_data = packet_data.split("|")
						var alarm_dict = json.parse_string(packet_data[0])
						var groups = json.parse_string(packet_data[1])
						for alarm in alarm_dict:
							var alarm_state = alarm_dict[alarm]["state"]
							alarms[alarm].state = int(alarm_state)
							alarms[alarm].silenced = bool(alarm_dict[alarm]["silenced"])

						for group in groups:
							var fast_state = groups[group]["F"]
							var slow_state = groups[group]["S"]
							alarm_groups[group]["F"] = bool(fast_state)
							alarm_groups[group]["S"] = bool(slow_state)

					server_packets.ROD_POSITION_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for rod in packet_data:
							rod_information[rod] = packet_data[rod]
							
					server_packets.BUTTON_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data)
						for button in packet_data:
							var data = packet_data[button]
							if buttons[button].updated == true: #if we have a update to this, we have to ignore what the server wants
								continue
							if button not in buttons:
								continue
							if buttons[button].switch != null:
								buttons[button].switch.button_state_change(data.state)
								buttons[button].switch.button_arm_change(data.armed)
					
					server_packets.PLAYER_POSITION_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data) # dict of all players, dict OR Vector3(?) of position
						for player in packet_data:
							var player_position = packet_data[player]["position"]
							var player_rotation = packet_data[player]["rotation"]
							
							if player == globals.username_requested_tojoin:
								continue #if the player is ourselves, ignore it
							
							if player in players:
								config.load("game.cfg")
								players[player].position = player_position
								players[player].rotation = player_rotation
							else:
								# player is not in our list, assume its a new player and insert a new entry
								players[player] = {
									"position" : player_position,
									"rotation" : player_rotation,
								}
								# actually create the other player character
								var NewRemotePlayer = remote_player_scene.instantiate()
								NewRemotePlayer.name = player
								self.add_child(NewRemotePlayer)
								players[player]["object"] = NewRemotePlayer
								# TODO: remove remote player instance when they disconnect
								
								
					server_packets.CHAT:
						chat_message.emit(packet_data)
						
					server_packets.RECORDER:
						packet_data = json.parse_string(packet_data)
						
						for recorder in packet_data:
							#var page_info = packet_data[recorder].page_info
							#var page = packet_data[recorder].page
							var channels = packet_data[recorder].channels
							
							var rcd = recorders[recorder]
								
							if rcd.update_time >= 10: #1 second, assuming the server or connection isnt lacking
								for channel in channels:
									if not channel in rcd.history:
										rcd.history[channel] = []
										rcd.history[channel].resize(600)
										rcd.history[channel].fill(0)
									
									if len(rcd.history[channel]) > 600:
										rcd.history[channel].remove_at(600) #TODO: use 1800
							
									rcd.history[channel].insert(0,channels[channel].value)
									
									
								rcd.update_time = 0
							
							rcd.update_time += 1
							
							if rcd.object != null:
								#rcd.object.update(page,page_info)
								rcd.object.update(channels,rcd.history)
					
			# check if any switches have been turned
			var updated_switches = {}
			for switch_name in switches:
				var switch = switches[switch_name]
				if switch.updated == true:
					updated_switches[switch_name] = {"position" : switch.position, "flag" : switch.flag} #TODO: should we trust the client's flag?
			
			# if switches have been turned, send them to the server
			if updated_switches != {}:
				var err = socket.send_text(build_packet(client_packets.SWITCH_PARAMETERS_UPDATE, json.stringify(updated_switches)))
				if not err:
					for switch in updated_switches:
						switches[switch].updated = false
				else:
					print(err)
					
			#check if any buttons have been pressed
			
			var updated_buttons = {}
			for button_name in buttons:
				var button = buttons[button_name]
				if button.updated == true:
					updated_buttons[button_name] = {"state" : button.state, "armed" : button.armed}
					
			if updated_buttons != {}:
				var err = socket.send_text(build_packet(client_packets.BUTTON_PARAMETERS_UPDATE, json.stringify(updated_buttons)))
				if not err:
					for button in updated_buttons:
						buttons[button].updated = false
				else:
					print(err)
					
			# TODO: only fire to server when our position updated
			
			if selected_rod != null:
				var err = socket.send_text(build_packet(client_packets.ROD_SELECT_UPDATE, json.stringify(selected_rod)))
				if not err:
					selected_rod = null
				else:
					print(err)
			
			
			var local_player_position = {}
			
			if not globals.use_vr:
				var local_player = get_node("Player")
			
				local_player_position = {globals.username_requested_tojoin : {
					"position":{
						"x" : local_player.position["x"],
						"y" : local_player.position["y"],
						"z" : local_player.position["z"],
					},
					"rotation":{
						"x" : local_player.rotation_degrees["x"],
						"y" : local_player.rotation_degrees["y"],
						"z" : local_player.rotation_degrees["z"],
					},
				}}
			
			if local_player_position != {}:
				var err = socket.send_text(build_packet(client_packets.PLAYER_POSITION_PARAMETERS_UPDATE, json.stringify(local_player_position)))
				if err:
					print(err)
					
			#TODO: add a script on each remote player that updates their own position (?)
			
			for player in players:
				var player_position = players[player].position
				var player_rotation = players[player].rotation
				var actual_position = players[player].object.position
				var twn = create_tween()
				twn.tween_property(players[player].object,"position",Vector3(player_position['x'],player_position['y'],player_position['z']),0.1)
				twn.set_trans(Tween.TRANS_LINEAR)
				twn.set_ease(Tween.EASE_IN_OUT)
				twn.play()
				players[player].object.rotation_degrees = Vector3(player_rotation['x'],player_rotation['y'],player_rotation['z'])
				
			for message in sent_messages:
				socket.send_text(build_packet(client_packets.CHAT, message))
			sent_messages.clear()
							
							
							
						
			if not synchronized:
				#request all the information for the client
				var err = socket.send_text(build_packet(client_packets.SYNCHRONIZE,"a")) #TODO: does it matter what text we send? can i use a different way?
				synchronized = true
					
		elif state == WebSocketPeer.STATE_CLOSING:
			# Keep polling to achieve proper close.
			pass
		elif state == WebSocketPeer.STATE_CLOSED:
			disconnected(socket) 
	else:
		if state == WebSocketPeer.STATE_OPEN:
			if not connection_packet_sent:
				var login_parameters = {
					"username": globals.username_requested_tojoin,
					"version": globals.version

					# TODO: make a seperate service for this, so the server doesn't have access to the unique id
					#"unique_id": OS.get_unique_id(),

				}
				var err = socket.send_text(build_packet(client_packets.USER_LOGIN, json.stringify(login_parameters)))
				if err: 
					disconnected(socket) 
				else:
					connection_packet_sent = true
					
			while socket.get_available_packet_count():
				var packet = socket.get_packet().get_string_from_utf8().split("|")
				var packet_id = int(packet[0])
				var packet_data = parse_b64(packet[1])
				
				if packet_id == server_packets.USER_LOGIN_ACK and info_got >= 5:
					if packet_data == "ok":
						connection_ready = true
						init_scene()
					else:
						globals.disconnect_msg = packet_data
						get_tree().change_scene_to_file("res://Assets/Scenes/Lobby/new_lobby.tscn")
						set_process(false)
	
				elif packet_id == server_packets.DOWNLOAD_DATA:
					packet_data = packet_data.split("|")
					var info = json.parse_string(packet_data[0])
					var info_name = json.parse_string(packet_data[1])
					
					match info_name:
						"switches":
							info_got += 1
							switches = info
							for switch in info:
								switch = info[switch]
								switch["switch"] = null
								switch["updated"] = false
									
								var positions = switch["positions"].duplicate()
								switch["positions"] = {}
								for position in positions:
									switch["positions"][int(position)] = positions[position]
									
							switches = info
									
						"buttons":
							info_got += 1
							
							buttons = info
							for button in buttons:
								button = buttons[button]
								button["switch"] = null
								button["momentary"] = false
								button["updated"] = false
						"alarms":
							info_got += 1
							
							alarms = info
							for alarm in alarms:
								alarm = alarms[alarm]
								alarm["material"] = null
								
						"rods":
							info_got += 1
							
							rod_information = info
								
						"recorders":
							info_got += 1
							
							recorders = info
							for recorder in recorders:
								recorder = recorders[recorder]
								recorder["object"] = null
								recorder["history"] = {}
								recorder["update_time"] = 11
								
					tables_received.append(info_name)
								
		elif state == WebSocketPeer.STATE_CONNECTING:
			connection_timeout += 1
			if connection_timeout > 300: #around 5 seconds
				socket.close()
				globals.disconnect_msg = "Client failed to connect in a timely manner. Please check your internet connection."
				get_tree().change_scene_to_file("res://Assets/Scenes/Lobby/new_lobby.tscn")
				set_process(false)
				
			
