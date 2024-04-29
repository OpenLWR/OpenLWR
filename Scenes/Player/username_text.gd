extends Node2D

func _ready():
	var username = self.get_parent().get_parent().get_parent().name #dont mind this mess
	$"Label".text = username
	
