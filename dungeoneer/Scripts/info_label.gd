extends Label
@export var info : Info = null

func _ready():
	info.connect("info_changed", update_info)

func update_info():
	self.text = info.print()
