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
}

var switches = {
	"reactor_mode_switch": {
		"switch": null,
		"positions": {
			0: 45, #Shutdown
			1: 0, #Refuel
			2: -45, #Startup
			3: -90, #Run
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights": {},
	},
	
	"irm_a_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	"irm_c_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	"irm_g_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	"irm_e_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	
	"irm_b_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	"irm_d_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	"irm_h_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	"irm_f_range": {
		"switch": null,
		"positions": {
			0: 90,
			1: 75,
			2: 60,
			3: 45,
			4: 30,
			5: 15,
			6: 0,
			7: -15,
			8: -30,
			9: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	
	
	"hpcs_p_1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"hpcs_p_3": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"hpcs_v_4": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"override" : null,
		},
	},
	"hpcs_v_1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"hpcs_v_12": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"hpcs_v_15": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"override" : null,
		},
	},
	"hpcs_v_23": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	"rhr_p_2b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_48b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_3b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_42b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45, 
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_4b": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_6b": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	"rhr_p_2c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_p_3": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_4c": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_42c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_24c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	#safety/relief valves
	"ms_rv_5b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_3d": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_5c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_4d": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_4b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_4a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_4c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_1a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_2b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_1c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_1b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_2c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_1d": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_3c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_2d": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_2a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_3b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	"ms_rv_3a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : true,
			"red" : false,
		},
	},
	
	"rcic_v_1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rcic_v_45": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rcic_v_8": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rcic_v_63": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rcic_v_68": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	"rcic_v_13": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rcic_v_31": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	#LPCS
	
	"lpcs_p_1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"lpcs_v_5": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"lpcs_v_11": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"lpcs_v_12": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"lpcs_v_1": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	"rhr_p_2a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_42a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_53a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_48a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_3a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_64a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_4a": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"rhr_v_6a": {
		"switch": null,
		"positions": {
			0: 45,
			1: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	#MSIVs (inboard)
	
	"ms_v_22a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"ms_v_22b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"ms_v_22c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"ms_v_22d": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	#MSIVs (outboard)
	
	"ms_v_28a": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"ms_v_28b": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"ms_v_28c": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	"ms_v_28d": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	"bypass_valve": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	
	"turbine_valve": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	
	"rfw_trip": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 0,
		"momentary": false,
		"updated": false,
		"lights" : {},
	},
	
	
	
	"cb_s1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"cb_s2": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"cb_s3": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	
	"cb_7_1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"cb_1_7": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"cb_3_8": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"cb_8_3": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	
	#DG1
	
	"cb_dg1_7": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"cb_7dg1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"diesel_gen_1": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
	#DG2
	
	"cb_dg2_8": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"cb_8dg2": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
			"lockout" : null,
		},
	},
	"diesel_gen_2": {
		"switch": null,
		"positions": {
			0: 45,
			1: 0,
			2: -45,
		},
		"position": 1,
		"momentary": false,
		"updated": false,
		"lights" : {
			"green" : null,
			"red" : null,
		},
	},
	
}

var buttons = {
	"SCRAM_A1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SCRAM_B1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SCRAM_A2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SCRAM_B2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"SCRAM_RESET_A": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SCRAM_RESET_B": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"ALARM_ACK_1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ALARM_RESET_1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"ALARM_ACK_2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ALARM_RESET_2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"ALARM_ACK_3": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ALARM_RESET_3": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"ACCUM_TROUBLE_RESET": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ROD_DRIFT_RESET": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"RMCS_INSERT_PB": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"RMCS_WITHDRAW_PB": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"RMCS_CONT_INSERT_PB": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"RMCS_CONT_WITHDRAW_PB": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"hpcs_init": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"SELECT_SRM_A": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_SRM_B": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_SRM_C": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_SRM_D": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"SELECT_IRM_A": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_IRM_B": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_IRM_C": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_IRM_D": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_IRM_E": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_IRM_F": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_IRM_G": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"SELECT_IRM_H": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"DET_DRIVE_IN": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"DET_DRIVE_OUT": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"rcic_init": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"rcic_init_reset": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	#MSIV Logic pushbuttons
	"msiv_logic_a": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"msiv_logic_b": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"msiv_logic_c": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"msiv_logic_d": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"isol_logic_reset_1": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"isol_logic_reset_2": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"lpcs_man_init": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"lpcs_init_reset": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"rwm_seq": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"rwm_rwm_comp_prog": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"rwm_diag": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"rwm_test": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"ehc_closed": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ehc_100": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ehc_500": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ehc_1500": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ehc_1800": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ehc_overspeed": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	
	"ehc_slow": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ehc_med": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
	"ehc_fast": {
		"switch": null,
		"state": false,
		"momentary": false,
		"armed" : false,
		"updated": false,
	},
}

enum annunciator_state {
	CLEAR = 0,
	ACTIVE = 1,
	ACKNOWLEDGED = 2,
	ACTIVE_CLEAR = 3,
}

var alarms = {
	"reactor_scram_a1_and_b1_loss": {
		"box": "Box1",
		"window": "1-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"1/2_scram_system_a": {
		"box": "Box1",
		"window": "3-4",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rpv_level_low_trip_a": {
		"box": "Box1",
		"window": "2-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rpv_press_high_trip_a": {
		"box": "Box1",
		"window": "2-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"mode_switch_in_shutdown_position_a": {
		"box": "Box1",
		"window": "5-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"neutron_monitor_system_trip_a": {
		"box": "Box1",
		"window": "3-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"msiv_closure_trip_a": {
		"box": "Box1",
		"window": "2-1",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"rod_accumulator_trouble": {
		"box": "Box1",
		"window": "6-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rpis_or_rwm_inop": {
		"box": "Box1",
		"window": "1-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rod_out_block": {
		"box": "Box1",
		"window": "2-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rod_drift": {
		"box": "Box1",
		"window": "5-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	#Ann A8
	"reactor_scram_a2_and_b2_loss": {
		"box": "Box2",
		"window": "1-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"1/2_scram_system_b": {
		"box": "Box2",
		"window": "3-4",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rpv_level_low_trip_b": {
		"box": "Box2",
		"window": "2-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rpv_press_high_trip_b": {
		"box": "Box2",
		"window": "2-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"mode_switch_in_shutdown_position_b": {
		"box": "Box2",
		"window": "5-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"neutron_monitor_system_trip_b": {
		"box": "Box2",
		"window": "3-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"msiv_closure_trip_b": {
		"box": "Box2",
		"window": "2-1",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"rbm_downscale": {
		"box": "Box2",
		"window": "6-6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rbm_upscale_or_inop": {
		"box": "Box2",
		"window": "3-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"irm_downscale": {
		"box": "Box1",
		"window": "4-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"irm_upscale": {
		"box": "Box1",
		"window": "3-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"irm_bdfh_upscl_trip_or_inop": {
		"box": "Box2",
		"window": "1-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"irm_aceg_upscl_trip_or_inop": {
		"box": "Box1",
		"window": "2-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"lprm_downscale": {
		"box": "Box2",
		"window": "5-6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"aprm_downscale": {
		"box": "Box2",
		"window": "4-6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"lprm_upscale": {
		"box": "Box2",
		"window": "2-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"aprm_upscale": {
		"box": "Box2",
		"window": "2-6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"aprm_ace_upscl_trip_or_inop": {
		"box": "Box1",
		"window": "1-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"aprm_bdf_upscl_trip_or_inop": {
		"box": "Box2",
		"window": "1-6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"setpoint_setdown_active": {
		"box": "Box2",
		"window": "2-7",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	#P601.A11
	"msiv_half_trip_system_b": {
		"box": "P601_A11",
		"window": "5-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rc_2_half_trip": {
		"box": "P601_A11",
		"window": "2-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	#P601.A12
	"msiv_half_trip_system_a": {
		"box": "P601_A12",
		"window": "2-1",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rc_1_half_trip": {
		"box": "P601_A12",
		"window": "4-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	"rcic_actuated": {
		"box": "P601_A4",
		"window": "1-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"rcic_turbine_trip": {
		"box": "P601_A4",
		"window": "1-5",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	#LPCS
	"lpcs_rhr_a_actuated": {
		"box": "P601_A3",
		"window": "1-3",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	"lpcs_rhr_a_init_rpv_level_low": {
		"box": "P601_A4",
		"window": "6-2",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
	
	#HPCS
	"hpcs_actuated": {
		"box": "P601_A1",
		"window": "1-6",
		"state": annunciator_state.CLEAR,
		"silenced" : false,
		"material": null,
	},
}

var alarm_groups = {
	"1" : {"F" : true, "S" : true}, # F - Fast S - Slow
	"2" : {"F" : true, "S" : true}, # F - Fast S - Slow
	"3" : {"F" : true, "S" : true}, # F - Fast S - Slow
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
	
}

var rod_information = {}

@onready var players = {
	#"1":{ #key is userid, for now its username
	#	"position" : {"x" : 0, "y" : 0, "z" : 0,}, # Can we use a Vector3 here?
	#	"username" : "john",
	#	"object" : null, #player object to manipulate, 
	#}
}

var selected_rod = null
@onready var tween = get_tree().create_tween()

var connection_ready = false
var connection_packet_sent = false

var sent_messages: PackedStringArray = PackedStringArray()

const remote_player_scene = preload("res://Assets/Scenes/Player/remote_player.tscn")
const vr_player_scene = preload("res://Assets/Scenes/Player/vr_player.tscn")
const pc_player_scene = preload("res://Assets/Scenes/Player/player.tscn")

func build_packet(packet_id, data):
	return "%s|%s" % [str(packet_id), Marshalls.utf8_to_base64(data)]

func build_rod_select():
	for rod in rod_information:
		var button = buttons["select_%s" % rod]
		
func disconnected(socket):
	var code = socket.get_close_code()
	var reason = socket.get_close_reason()
	print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
	#kick to lobby screen
	get_tree().change_scene_to_file("res://Assets/Scenes/Lobby/new_lobby.tscn")
	set_process(false) # Stop processing.

func _ready(): # assume here that the scene was called by the lobby screen
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
	var endpoint = "ws://%s/ws" % [globals.server_ip_requested_tojoin] # TODO: should token be generated on server-side?
	socket.connect_to_url(endpoint)
	

	
func parse_b64(b64):
	return Marshalls.base64_to_utf8(b64)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	globals.connection_state = state
	if connection_ready:
		if state == WebSocketPeer.STATE_OPEN:
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
					"x" : local_player.position["x"],
					"y" : local_player.position["y"],
					"z" : local_player.position["z"],
				}}
			
				if local_player_position != {}:
					var err = socket.send_text(build_packet(client_packets.PLAYER_POSITION_PARAMETERS_UPDATE, json.stringify(local_player_position)))
					if err:
						print(err)
					
			#TODO: add a script on each remote player that updates their own position (?)
			
			for player in players:
				var player_position = players[player].position
				var actual_position = players[player].object.position
				var twn = create_tween()
				twn.tween_property(players[player].object,"position",Vector3(player_position['x'],player_position['y'],player_position['z']),0.1)
				twn.set_trans(Tween.TRANS_LINEAR)
				twn.set_ease(Tween.EASE_IN_OUT)
				twn.play()
				
			for message in sent_messages:
				socket.send_text(build_packet(client_packets.CHAT, message))
			sent_messages.clear()
			
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
							if button not in buttons:
								continue
							if buttons[button].switch != null:
								buttons[button].switch.button_state_change(data.state)
								buttons[button].switch.button_arm_change(data.armed)
					
					server_packets.PLAYER_POSITION_PARAMETERS_UPDATE:
						packet_data = json.parse_string(packet_data) # dict of all players, dict OR Vector3(?) of position
						for player in packet_data:
							var player_position = packet_data[player]
							
							if player == globals.username_requested_tojoin:
								break #if the player is ourselves, ignore it
							
							if player in players:
								players[player].position = player_position
							else:
								# player is not in our list, assume its a new player and insert a new entry
								players[player] = {
									"position" : player_position,
								}
								# actually create the other player character
								var NewRemotePlayer = remote_player_scene.instantiate()
								NewRemotePlayer.name = player
								self.add_child(NewRemotePlayer)
								players[player]["object"] = NewRemotePlayer
								# TODO: remove remote player instance when they disconnect
								
								
					server_packets.CHAT:
						chat_message.emit(packet_data)
					
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
				
				if packet_id == server_packets.USER_LOGIN_ACK:
					connection_ready = true
					#request all the information for the client
					var err = socket.send_text(build_packet(client_packets.SYNCHRONIZE,"a")) #TODO: does it matter what text we send? can i use a different way?

