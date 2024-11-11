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

func end_boot():
	var boot = $"Recorder/Screen/Node2D/BOOT"
	var pgs = $"Recorder/Screen/Node2D/PAGES"
	var elem = $"Recorder/Screen/Node2D/ELEMENTS"
	var blue = $"Recorder/Screen/Node2D/BOOT/Blue"
	var white = $"Recorder/Screen/Node2D/BOOT/White"
	
	boot.visible = false
	pgs.visible = true
	elem.visible = true
	blue.visible = true
	white.visible = false
	
func shut_down():
	var boot = $"Recorder/Screen/Node2D/BOOT"
	var pgs = $"Recorder/Screen/Node2D/PAGES"
	var elem = $"Recorder/Screen/Node2D/ELEMENTS"
	var blue = $"Recorder/Screen/Node2D/BOOT/Blue"
	var white = $"Recorder/Screen/Node2D/BOOT/White"
	boot.visible = false
	pgs.visible = false
	elem.visible = false
	blue.visible = true
	white.visible = false
	
func do_boot(time):
	time *= 0.1
	var boot = $"Recorder/Screen/Node2D/BOOT"
	var blue = $"Recorder/Screen/Node2D/BOOT/Blue"
	var white = $"Recorder/Screen/Node2D/BOOT/White"
	var code = $"Recorder/Screen/Node2D/BOOT/Blue/Code"
	var finish = $"Recorder/Screen/Node2D/BOOT/Blue/Finish"
	var diag = $"Recorder/Screen/Node2D/BOOT/White/Text"
	match int(time):
		25:
			white.visible = false
			blue.visible = true
			finish.visible = false
			boot.visible = true
			
			code.text = "Code"
		23:
			code.text = "Code OK"
		22:
			code.text = "Code OK >"
		21: 
			code.text = "Code OK >>"
		20: 
			code.text = "Code OK >>>"
		19: 
			code.text = "Code OK >>>>"
		18: 
			code.text = "Code OK >>>>>"
		17: 
			code.text = "Code OK >>>>>"
		16: 
			code.text = "Code OK >>>>>>"
		15: 
			code.text = "Code OK >>>>>>>"
		14: 
			code.text = "Code OK >>>>>>>>"
		13:
			finish.visible = true
		12:
			diag.visible = false
			blue.visible = false
			white.visible = true
		8:
			diag.visible = true

func update(info):
	var page = info.page
	if info.display_on and info.boot_time == 1:
		end_boot()
		
		$"Recorder/recorder/Cube_005".material_override = screen_material
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
	elif info.display_on and info.boot_time == -1:
		$"Recorder/recorder/Cube_005".material_override = screen_material
		node_3d.recorders[self.name].boot_time = 249
		do_boot(250)
	elif info.display_on and info.boot_time > 1:
		do_boot(info.boot_time)
		node_3d.recorders[self.name].boot_time -= 1
	else:
		shut_down()
		$"Recorder/recorder/Cube_005".material_override = null
		node_3d.recorders[self.name].boot_time = -1
	
