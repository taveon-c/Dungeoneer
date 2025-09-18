extends Label
@export var info : Info = null

func _ready():
	if info != null:
		info.connect("info_changed", update_info)

func update_info():
	if info == null:
		self.text = owner.info.print()
	else:
		self.text = info.print()
