extends Node2D

func update(info):
	var ch_num = 1
	var channels = info.channels
	for channel_n in channels:
		var channel = channels[channel_n]
		
		var unit = channel.unit
		var text = channel.text
		
		#we only have two
		get_node("%s_NAME" % str(ch_num)).text = channel_n
		get_node("%s_UNIT" % str(ch_num)).text = unit
		get_node("%s_VALUE" % str(ch_num)).text = text
		
		ch_num += 1
