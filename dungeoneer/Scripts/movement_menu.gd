extends CanvasLayer

@onready var Menu = $"../Main"
@onready var Hints : Node = $"../Hints"
@onready var Map : TileMapLayer = $"../TileMapLayer"
var is_moving : bool = false

func _process(delta: float) -> void:
	if is_moving:
		var Player = get_tree().get_first_node_in_group("player")
		Hints.clear_hints()
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				var direction = Vector2(x, y)
				if direction != Vector2.ZERO:
					Hints.generate_hint(Color.DEEP_SKY_BLUE, Player.global_position + direction * 16 - Vector2(8, 8))
		
		var mouse_position = Player.get_global_mouse_position()
		var direction = Player.global_position.direction_to(mouse_position).round()
		if direction != Vector2.ZERO:
			var new_position = Player.global_position + direction * 16
			if Map.get_cell_atlas_coords(Map.local_to_map(new_position)) == Vector2i(0, 0) and mouse_position.distance_to(Player.global_position) < 32:
				Hints.generate_hint(Color.DEEP_SKY_BLUE, new_position - Vector2(8, 8))
				if Input.is_action_just_pressed("select"):
					Player.move(direction)

func _on_move_pressed() -> void:
	self.visible = true
	Menu.visible = false
	is_moving = true

func _on_exit_pressed() -> void:
	self.visible = false
	is_moving = false
	Hints.clear_hints()
	
	Menu.visible = true
