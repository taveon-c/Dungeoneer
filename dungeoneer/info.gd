extends CanvasLayer
@onready var label = self.get_child(0)
@export var stats : Stats

func format_info():
	var string : String = ""
	print(stats.get_property_list())
	for property in stats.get_property_list():
		if not "script" in property.name and not "resource" in property.name and property.name == property.name.to_lower():
			string = string + property.name + ": " + str(stats.get(property.name)) + "\n"
	label.text = string

func _ready() -> void:
	format_info()
