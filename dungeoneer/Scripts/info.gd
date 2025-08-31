extends Label
@export var parent : Node2D = null
@export var stats : Stats = null

func _ready() -> void:
	update_info()

func update_info():
	if stats == null:
		if parent.stats == null:
			self.text = parent.base_stats.print()
		else:
			self.text = parent.stats.print()
	elif parent == null:
		self.text = stats.print()
