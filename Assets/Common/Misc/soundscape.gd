extends Node3D

#get the area so we can detect when the player is inside the soundscape
@onready var soundscape_area = $Area3D
@onready var sound_player = $area_audio

func soundscape_entered(_body):
	#we dont have to check here what collided because the player is on the 1&2 collision layer
	#and the area is on the 2 layer, so we will only pickup the player
	if sound_player.playing == false:
		sound_player.playing = true
		
func soundscape_exited(_body):

	if sound_player.playing == true:
		sound_player.playing = false
	

func _ready():
	#connect to the node's "body_entered" and "body_exited" signals
	soundscape_area.connect("body_entered",soundscape_entered)
	soundscape_area.connect("body_exited",soundscape_exited)
