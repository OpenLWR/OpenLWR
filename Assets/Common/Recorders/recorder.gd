extends Node3D

@onready var node_3d = $"/root/Node3D"
@onready var screen_material = $"Recorder/recorder/Cube_005".material_override #you can set the material of this guy to null to make it turn off?
var recorder

func init():
	recorder = node_3d.recorders[self.name]
	recorder.object = self
	recorder.updated = false

func _ready():
	node_3d.init_scene_objects.connect(init)
	var children = $"Recorder/Buttons".get_children()
	for child in children:
		child.updated.connect(button_changed)
	
func button_changed():
	var children = $"Recorder/Buttons".get_children()
	for child in children:
		var state = child.state
		var name = child.name
		
		if name in recorder.buttons:
			recorder.buttons[name] = state
		
	recorder.updated = true
	
func update(info):
	var page = info.page
	get_node("Recorder/Screen/Node2D/PAGES/%s_PAGE" % str(page)).update(info)
	
	var children = $"Recorder/Screen/Node2D/PAGES".get_children()
	for child in children:
		if child.name != str(page)+"_PAGE":
			child.visible = false
		else:
			child.visible = true
			
	var children_elements = $"Recorder/Screen/Node2D/ELEMENTS".get_children()
	for child in children_elements:
		child.visible = info.elements[child.name]["SHOW"]
	
