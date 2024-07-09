extends CSGBox3D

@onready var node_3d = $"/root/Node3D"
@onready var light = self.get_material()

func _ready():
	
	while node_3d.rod_information == {}:
		await get_tree().create_timer(0.1).timeout
	
	while true:
		light.emission_enabled = node_3d.rod_information[self.name]["select"]
		await get_tree().create_timer(0.1).timeout


func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1:
		var rod = self.name
		node_3d.selected_rod = rod
