extends Control


func _ready():
	set_quality_dropdown(get_node("OptionButton"))
	
#TODO: actually set graphics quality
func set_quality_dropdown(dropdown):
	dropdown.add_item("Wtf man")
	dropdown.add_item("Very high")
	dropdown.add_item("High")
	dropdown.add_item("Medium")
	dropdown.add_item("Low")
	dropdown.add_item("Potato")
