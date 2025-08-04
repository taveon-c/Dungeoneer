extends CanvasLayer

@onready var Player = $"../Player"
@onready var Menu = $"../Main"
@onready var Hints : Node = $"../Hints"
@onready var Info : CanvasLayer = $"../Info"
@onready var Map : TileMapLayer = $"../TileMapLayer"
var is_moving : bool = false

func _process(delta: float) -> void:
	if is_moving:
		Hints.clear_hints()
		var mouse_position = Player.get_global_mouse_position()
		var direction = Player.global_position.direction_to(mouse_position).round()
		var new_position = Player.global_position + direction * 16
		if Map.get_cell_source_id(Map.local_to_map(new_position)) == -1 and mouse_position.distance_to(Player.global_position) < 32:
			Hints.generate_hint(Color.DEEP_SKY_BLUE, new_position)
			if Input.is_action_just_pressed("select"):
				Player.global_position = new_position

func _on_move_pressed() -> void:
	self.visible = true
	Menu.visible = false
	is_moving = true

func _on_undo_pressed() -> void:
	print("undo")
	#if Player.path.size() > 0:
		#Player.path.pop_back()
		#Player.update_player_hints()
		#Info.update_turn()
		#if Player.path.size() == 0:
			#Origin.global_position = Player.global_position
		#else:
			#Origin.global_position = Player.path.back()

func _on_cancel_pressed() -> void:
	self.visible = false
	is_moving = false
	Hints.clear_hints()
	Info.update_turn()
	
	Menu.visible = true
