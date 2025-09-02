extends Button

func _ready() -> void:
	var level = owner.owner
	connect("pressed", level._on_turn_end)
	connect("pressed", self.owner.set_visible.bind(false))
