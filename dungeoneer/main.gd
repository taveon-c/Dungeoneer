extends CanvasLayer
@onready var action_button : Button = $"Action"
@onready var action_menu : CanvasLayer = $"../Action"

func _ready() -> void:
	action_button.text = "Attack"
	action_button.pressed.connect(action_menu._on_action_pressed)
		
func _on_end_turn():
	self.visible = false
