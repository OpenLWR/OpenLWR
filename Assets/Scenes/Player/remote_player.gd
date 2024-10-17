extends CharacterBody3D

func set_name_billboard(name:String):
	get_node("Sprite3D/SubViewport/Node2D/Label").text = name

	
