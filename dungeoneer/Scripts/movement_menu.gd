extends CanvasLayer

@onready var Player = $"../Player"
@onready var Menu_Action = $"../Action"
@onready var Origin : Node2D = $"../Origin"
@onready var Info : CanvasLayer = $"../Info"
var is_moving : bool = false

func _process(delta: float) -> void:
	if is_moving:
		Origin.visible = Player.path.size() < Player.move_points
		
		if Input.is_action_just_pressed("select") and Origin.visible:
			var mouse_position =  (Origin.get_global_mouse_position() - Vector2(8,8)).snappedf(16.0)
			for marker in Origin.get_children():
				if marker.global_position == mouse_position:
					Origin.global_position = mouse_position
					Player.path.append(mouse_position)
					Player.update_player_hints()
					Info.update_turn()
		
		Origin.visible = Player.path.size() < Player.move_points

func _on_move_pressed() -> void:
	self.visible = true
	Menu_Action.visible = false
	Origin.visible = true
	is_moving = true

func _on_exit_pressed() -> void:
	self.visible = false
	Menu_Action.visible = true
	Origin.visible = false
	is_moving = false

func _on_undo_pressed() -> void:
	if Player.path.size() > 0:
		Player.path.pop_back()
		Player.update_player_hints()
		Info.update_turn()
		if Player.path.size() == 0:
			Origin.global_position = Player.global_position
		else:
			Origin.global_position = Player.path.back()
