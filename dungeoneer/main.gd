extends CanvasLayer
@onready var container : HBoxContainer = $"Action Container"
@onready var action_menu : CanvasLayer = $"../Action"
@onready var player : Sprite2D = $"../Player"

func _ready() -> void:
	for action in player.weapon.actions.keys():
		var action_button = Button.new()
		action_button.text = action
		action_button.pressed.connect(action_menu._on_action_pressed.bind(action))
		container.add_child(action_button)
		
