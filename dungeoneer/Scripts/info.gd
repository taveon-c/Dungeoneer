extends Label
@export var stats : Stats = null

func _ready():
	if stats != null:
		stats.connect("stats_changed", update_info)

func update_info():
	if stats == null:
		self.text = owner.stats.print()
	else:
		self.text = stats.print()
