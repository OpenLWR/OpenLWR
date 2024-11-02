extends Node3D

@onready var node_3d = $"/root/Node3D"
var recorder
@onready var material = $"recorder/Sprite3D/SubViewport/Node2D/PAGES/2_PAGE/Graph".get_material()

func init():
	recorder = node_3d.recorders[self.name]
	recorder.object = self
	recorder.updated = false
	material.set_shader_parameter("maxValue", 200);
	material.set_shader_parameter("minValue", -200);
	material.set_shader_parameter("color",Vector4(0.95, 0.33, 0.3, 1.0));
	material.set_shader_parameter("lineThickness", 0.01)

func _ready():
	node_3d.init_scene_objects.connect(init)
	var children = $"recorder/Buttons".get_children()
	for child in children:
		child.updated.connect(button_changed)
	
func button_changed():
	var children = $"recorder/Buttons".get_children()
	for child in children:
		var state = child.state
		var name = child.name
		
		if name in recorder.buttons:
			recorder.buttons[name] = state
		
	recorder.updated = true
	
func update(info):
	var page = info.page
	get_node("recorder/Sprite3D/SubViewport/Node2D/PAGES/%s_PAGE" % str(page)).update(info)
	
	var children = $"recorder/Sprite3D/SubViewport/Node2D/PAGES".get_children()
	for child in children:
		if child.name != str(page)+"_PAGE":
			child.visible = false
		else:
			child.visible = true
			
	var children_elements = $"recorder/Sprite3D/SubViewport/Node2D/ELEMENTS".get_children()
	for child in children_elements:
		child.visible = info.elements[child.name]["SHOW"]
	
