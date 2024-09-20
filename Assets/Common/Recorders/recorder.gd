extends Node3D

@onready var node_3d = $"/root/Node3D"
var recorder
@onready var material = $"recorder/Sprite3D/SubViewport/Node2D/2_PAGE/Graph".get_material()

func init():
	recorder = node_3d.recorders[self.name]
	recorder.object = self
	material.set_shader_parameter("maxValue", 200);
	material.set_shader_parameter("minValue", -200);
	material.set_shader_parameter("color",Vector4(0.95, 0.33, 0.3, 1.0));
	material.set_shader_parameter("lineThickness", 0.01)

func _ready():
	node_3d.init_scene_objects.connect(init)
	
func update(channels,history):
	for channel_n in channels:
		var channel = channels[channel_n]
		var unit = channel.unit
		var text = channel.text
		
		#TODO: Pass a page number
		#When passing a page number, the data required for that page will be passed instead of channels
		
		#material.set_shader_parameter("maxValue", channels[channel_n]["+over"]);
		#material.set_shader_parameter("minValue", channels[channel_n]["-over"]);
		
		material.set_shader_parameter("data", history[channel_n]);
		material.set_shader_parameter("dataPoints", history[channel_n].size());
		
		$"recorder/Sprite3D/SubViewport/Node2D/1_PAGE/1_NAME".text = channel_n
		$"recorder/Sprite3D/SubViewport/Node2D/1_PAGE/1_UNIT".text = unit
		$"recorder/Sprite3D/SubViewport/Node2D/1_PAGE/1_VALUE".text = text
		
		$"recorder/Sprite3D/SubViewport/Node2D/2_PAGE/1_NAME".text = channel_n
		$"recorder/Sprite3D/SubViewport/Node2D/2_PAGE/1_UNIT".text = unit
		$"recorder/Sprite3D/SubViewport/Node2D/2_PAGE/1_VALUE".text = text
