extends CanvasLayer
@onready var action_button : Button = $"Action"
@onready var action_menu : CanvasLayer = $"../Action"
@onready var player : Sprite2D = $"../Player"

func _ready() -> void:
	action_button.text = player.weapon.action_name
	action_button.pressed.connect(action_menu._on_action_pressed)
		
func _on_end_turn():
	self.visible = false
