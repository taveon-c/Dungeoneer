extends CanvasLayer

@onready var Menu : CanvasLayer = $"../Main"
@onready var Info : CanvasLayer = $"../Info"
@onready var Origin : Node2D = $"../Origin"
@onready var Player : Node2D = $"../Player"
var action : String

func _process(delta: float) -> void:
	if not action.is_empty():
		var mouse_position =  (Origin.get_global_mouse_position() - Vector2(8,8)).snappedf(16.0)
		if Input.is_action_just_pressed("select"):
			for marker in Origin.get_children():
				if marker.global_position == mouse_position:
					Player.action.clear()
					var direction = marker.position
					Player.action = Player.weapon.actions[action].call(direction)
					Player.update_player_hints()
					Info.update_turn()
					

func _on_action_pressed(action : String) -> void:
	Menu.visible = false
	self.visible = true
	Origin.visible = true
	self.action = action

func _on_cancel_pressed() -> void:
	self.visible = false
	Origin.visible = false
	self.action = ""
	
	Menu.visible = true
	Player.action.clear()
	Player.update_player_hints()
	Info.update_turn()
