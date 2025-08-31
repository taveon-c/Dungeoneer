extends Label
@export var parent : Node2D = null
@export var stats : Stats = null

func _ready() -> void:
	if stats == null:
		parent.stats = parent.base_stats.duplicate()
		stats = parent.stats
	stats.connect("stats_changed", update_info)
	update_info()

func update_info():
	self.text = stats.print()
