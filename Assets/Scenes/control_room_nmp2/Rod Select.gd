extends Node3D

@onready var node3d = $"/root/Node3D"

func _ready():
	while true:
		await get_tree().create_timer(0.1).timeout
		for rod in node3d.rod_information:
			var info = node3d.rod_information[rod]
			
