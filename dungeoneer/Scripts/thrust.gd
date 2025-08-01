extends CanvasLayer

@onready var Menu_Action : CanvasLayer = $"../Action"
@onready var Info : CanvasLayer = $"../Info"
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
					var direction = Origin.global_position.direction_to(mouse_position)
					var position = Origin.global_position
					
					var attack_info = Player.weapon.thrust(direction, position)
					for space in attack_info["spaces"]:
						Player.attack.append(space)
					Player.attack_cost = 1
					Player.update_player_hints()
					Info.update_turn()
					

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
	Player.attack_cost = 0
	Player.update_player_hints()
	Info.update_turn()
