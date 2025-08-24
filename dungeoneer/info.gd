extends CanvasLayer
@onready var label = self.get_child(0)
@export var stats : Stats

func update_info():
	label.text = stats.print()

func _ready() -> void:
	update_info()
