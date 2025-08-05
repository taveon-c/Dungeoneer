extends CanvasLayer

@onready var Menu : CanvasLayer = $"../Main"
@onready var Info : CanvasLayer = $"../Info"
@onready var Player : Node2D = $"../Player"
@onready var Hints : Node = $"../Hints"
var is_action : bool

func _process(delta: float) -> void:
	if is_action:
		Hints.clear_hints()
		var mouse_position = Player.get_global_mouse_position()
		var action_info = Player.weapon.action.call(mouse_position, Player)
		for hint in action_info["hints"]:
			Hints.generate_hint(Color.RED, hint)
		if action_info["cost"] <= Player.energy and mouse_position.distance_to(Player.global_position) < 50:
			for space in action_info["spaces"]:
				Hints.generate_hint(Color.RED, space)
			if Input.is_action_just_pressed("select"):
				for space in action_info["spaces"]:
					pass #deal damage
				Player.energy -= action_info["cost"]
				Info.update_turn()
					

func _on_action_pressed() -> void:
	Menu.visible = false
	self.visible = true
	self.is_action = true

func _on_exit_pressed() -> void:
	Hints.clear_hints()
	self.visible = false
	self.is_action = false
	
	Menu.visible = true
