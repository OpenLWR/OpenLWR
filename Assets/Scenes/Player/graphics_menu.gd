extends Control

var Resolutions = {
	"2560x1440":Vector2(2560,1440),
	"1920x1080":Vector2(1920,1080),
	"1536x864":Vector2(1536,864),
	"1366x768":Vector2(1366,768),
	"1280x720":Vector2(1280,720),
}

@onready var viewport = get_viewport()

func _ready():
	set_occlusion_dropdown(get_node("Occlusion"))
	set_antialiasing_dropdown(get_node("Antialiasing"))
	set_vsync_dropdown(get_node("Vsync"))
	set_resolution_dropdown(get_node("Resolution"))
	viewport.msaa_3d = 3
	viewport.use_taa = false
	viewport.use_occlusion_culling = true
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
func set_resolution_dropdown(dropdown):
	for r in Resolutions:
		dropdown.add_item(r)
	
#TODO: actually set graphics quality
func set_occlusion_dropdown(dropdown):
	dropdown.add_item("On")
	dropdown.add_item("Off")

func _new_occlusion_selected(index):
	var viewport = get_viewport()
	viewport.use_occlusion_culling = index == 1
	
func set_antialiasing_dropdown(dropdown):
	dropdown.add_item("MSAA 8x")
	dropdown.add_item("MSAA 4x")
	dropdown.add_item("MSAA 2x")
	dropdown.add_item("TAA")
	dropdown.add_item("DISABLED")

func _new_antialiasing_selected(index):
	var viewport = get_viewport()
	if index == 1:
		viewport.msaa_3d = 3
		viewport.use_taa = false
	elif index == 2:
		viewport.msaa_3d = 2
		viewport.use_taa = false
	elif index == 3:
		viewport.msaa_3d = 1
		viewport.use_taa = false
	elif index == 4:
		viewport.msaa_3d = 0
		viewport.use_taa = true
	elif index == 5:
		viewport.msaa_3d = 0
		viewport.use_taa = false

func set_vsync_dropdown(dropdown):
	dropdown.add_item("On")
	dropdown.add_item("Disabled")

func _new_vsync_selected(index):
	if index == 1:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
func new_resolution_selected(index):
	var size = Resolutions.get(get_node("Resolution").get_item_text(index))
	#compares the size to 1920x1080
	var scale_factor = size[0]/1920
	viewport.scaling_3d_scale = scale_factor
	#DisplayServer.window_set_size(size)
