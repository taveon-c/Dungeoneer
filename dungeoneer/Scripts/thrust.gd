extends CanvasLayer

@onready var Menu_Action : CanvasLayer = $"../Action"
@onready var Origin : Node2D = $"../Origin"
@onready var Player : Node2D = $"../Player"
var is_thrusting : bool = false

func _process(delta: float) -> void:
	if is_thrusting:
		var mouse_position =  (Origin.get_global_mouse_position() - Vector2(8,8)).snappedf(16.0)
		if Input.is_action_just_pressed("select"):
			for marker in Origin.get_children():
				if marker.global_position == mouse_position:
					Player.attack.clear()
					Player.attack.append(marker.position)
					Player.update_player_hints()

func _on_thrust_pressed() -> void:
	Menu_Action.visible = false
	self.visible = true
	Origin.visible = true
	is_thrusting = true

func _on_exit_pressed() -> void:
	Menu_Action.visible = true
	self.visible = false
	Origin.visible = false
	is_thrusting = false

func _on_undo_pressed() -> void:
	Player.attack.clear()
	Player.update_player_hints()
