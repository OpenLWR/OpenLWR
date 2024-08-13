extends Node3D

@onready var node_3d = $"/root/Node3D"
var recorder 

func init():
	recorder = node_3d.recorders[self.name]
	recorder.object = self

func _ready():
	node_3d.init_scene_objects.connect(init)
	
func update(channels):
	for channel_n in channels:
		var channel = channels[channel_n]
		var unit = channel.unit
		var text = channel.text
		
		#TODO: Pass a page number
		#When passing a page number, the data required for that page will be passed instead of channels
		
		$"recorder/Sprite3D/SubViewport/Node2D/1_PAGE/1_NAME".text = channel_n
		$"recorder/Sprite3D/SubViewport/Node2D/1_PAGE/1_UNIT".text = unit
		$"recorder/Sprite3D/SubViewport/Node2D/1_PAGE/1_VALUE".text = text

