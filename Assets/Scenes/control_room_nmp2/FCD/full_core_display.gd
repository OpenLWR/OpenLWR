extends Node3D
@onready var node_3d = $"/root/Node3D"

var thread
var cycles = 0
var insertion
var rpis_inop = false #TODO: make these replicate from server
var fcd_inop = false #TODO: make these replicate from server

var image: Image
var texture: ImageTexture

enum LightState {
	OFF = 0,
	ON = 1,
	FLASHING = 2,
}

const ACTIVATED_STATES = {
	#&"ACCUM": LightState.FLASHING, # handled seperately
	&"SCRAM": LightState.ON,
	&"DRIFT": LightState.ON,
	&"SELECT": LightState.ON,
	&"FULL_IN": LightState.ON,
	&"FULL_OUT": LightState.ON,
}

const BLOCK_OFFSETS = {
	&"ACCUM": Vector2i(0, 1),
	&"SCRAM": Vector2i(0, 1),
	&"DRIFT": Vector2i(0, 0),
	&"SELECT": Vector2i(0, 0),
	&"FULL_IN": Vector2i(1, 0),
	&"FULL_OUT": Vector2i(1, 0),
}

const BOTTOM_TYPE_OF_BLOCK = {
	&"ACCUM": false,
	&"SCRAM": true,
	&"DRIFT": true,
	&"SELECT": false,
	&"FULL_IN": false,
	&"FULL_OUT": true,
}

func _get_light_offset(rod: Vector2i, type: StringName) -> Vector2i:
	rod -= Vector2i(2, 3)
	rod /= 4
	var flip = Vector2i(1 if rod.x % 2 == 1 else -1, 1 if rod.y % 2 == 1 else -1)
	var offset = Vector2i(1 if rod.x % 2 == 0 else 0, 1 if rod.y % 2 == 0 else 0)
	rod *= 2
	rod += offset
	rod += BLOCK_OFFSETS[type] * flip
	rod.y *= 2
	if BOTTOM_TYPE_OF_BLOCK[type]:
		rod.y -= 1
	rod.y = image.get_size().y - rod.y - 2
	return rod

#TODO: table with all the materials instead of this garbage

func _set_rod_light_emission(rod: Vector2i, light: StringName, state: LightState, target: Image):
	rod = _get_light_offset(rod, light)
	var color = target.get_pixelv(rod)
	color.b = (state + 0.5) / 3
	target.set_pixelv(rod, color)
	pass

func _set_rod_light_state(rod: Vector2i, light: StringName, state: LightState, target:Image):
	return _set_rod_light_emission(rod, light, state if not rpis_inop else LightState.OFF, target)

func _set_rod_light(rod: Vector2i, light: StringName, state: bool, target: Image):
	return _set_rod_light_state(rod, light, ACTIVATED_STATES[light] if state else LightState.OFF, target)

func _ready():
	var prev_texture = $shaderfcd.material_override["shader_parameter/rods"]
	image = prev_texture.get_image()
	texture = ImageTexture.create_from_image(image)
	$shaderfcd.material_override["shader_parameter/rods"] = texture
	pass

func _process(delta):
	pass


func _on_node_3d_rods_updated(new_info):
	for rod_number in new_info:
		var rod_info = new_info[rod_number]
		var insertion = rod_info.insertion
		rod_number = rod_number.split("-")
		var rod = Vector2i(int(rod_number[0]), int(rod_number[1]))
		_set_rod_light(rod, &"FULL_IN", insertion == 0, image)
		_set_rod_light(rod, &"FULL_OUT", insertion == 48, image)
		_set_rod_light(rod, &"SCRAM", rod_info.scram, image)
		_set_rod_light(rod, &"DRIFT", rod_info.drift_alarm, image)
		_set_rod_light(rod, &"SELECT", rod_info.select, image)
		var accum_state = LightState.FLASHING if not rod_info.accum_trouble_acknowledged else LightState.ON
		_set_rod_light_state(rod, &"ACCUM", accum_state if rod_info.accum_trouble else LightState.OFF, image)
		
	#_set_rod_light_emission(Vector2i(18, 03), &"SELECT", true, image)
	texture.update(image)
	pass # Replace with function body.
