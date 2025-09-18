extends CanvasLayer
enum State {
	NONE,
	MOVE,
	ATTACK,
	PICKUP
}
var player : StaticBody2D
@export var player_info_label : Label
@export var select_info_label : Label
@export var map : TileMapLayer
@export var level_info : LevelInfo
@export var current_state: State

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position = get_parent().get_global_mouse_position()
		var items = get_tree().get_nodes_in_group("item")
		var enemies = get_tree().get_nodes_in_group("enemy")
		for item in items:
			if item.global_position == map.map_to_local(map.local_to_map(mouse_position)):
				select_info_label.display_item_info(item.item)
		for enemy in enemies:
			if enemy.global_position == map.map_to_local(map.local_to_map(mouse_position)):
				select_info_label.display_enemy_info(enemy.info)

func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE:
			player.hints.clear_hints()
			if player.info.energy >= player.info.weight:
				for x in [-1, 0, 1]:
					for y in [-1, 0, 1]:
						var direction = Vector2(x, y)
						if direction != Vector2.ZERO:
							player.hints.generate_hint(Color.DEEP_SKY_BLUE, player.global_position + direction * level_info.TILE_SIZE - Vector2(level_info.TILE_SIZE/2, level_info.TILE_SIZE/2))
				
				var mouse_position = player.get_global_mouse_position()
				var direction = player.global_position.direction_to(mouse_position).round()
				if direction != Vector2.ZERO:
					var new_position = player.global_position + direction * level_info.TILE_SIZE
					if map.get_cell_atlas_coords(map.local_to_map(new_position)) == Vector2i(0, 0) and mouse_position.distance_to(player.global_position) < level_info.TILE_SIZE * 2:
						player.hints.generate_hint(Color.DEEP_SKY_BLUE, new_position - Vector2(level_info.TILE_SIZE/2, level_info.TILE_SIZE/2))
						if Input.is_action_just_pressed("select"):
							player.move(direction)
		State.ATTACK:
			player.hints.clear_hints()
			if player.info.weapon.cost <= player.info.energy:
				var mouse_position : Vector2 = player.get_global_mouse_position()
				var action_info = player.info.weapon.action(mouse_position, player)
				for hint in action_info["hints"]:
					player.hints.generate_hint(Color.RED, hint)
				if mouse_position.distance_to(player.global_position) < (player.info.weapon.range + 1) * level_info.TILE_SIZE:
					for space in action_info["spaces"]:
						player.hints.generate_hint(Color.RED, space - Vector2(level_info.TILE_SIZE/2, level_info.TILE_SIZE/2))
					if Input.is_action_just_pressed("select"):
						player.attack(action_info)
		State.PICKUP:
			player.hints.clear_hints()
			for x in [-1, 0, 1]:
				for y in [-1, 0, 1]:
					var direction = Vector2(x, y)
					if direction != Vector2.ZERO:
						player.hints.generate_hint(Color.WHITE, player.global_position + direction * level_info.TILE_SIZE - Vector2(level_info.TILE_SIZE/2, level_info.TILE_SIZE/2))
			
			var mouse_position = player.get_global_mouse_position()
			var direction = player.global_position.direction_to(mouse_position).round()
			if direction != Vector2.ZERO:
				var new_position = player.global_position + direction * level_info.TILE_SIZE
				if map.get_cell_atlas_coords(map.local_to_map(new_position)) == Vector2i(0, 0) and mouse_position.distance_to(player.global_position) < level_info.TILE_SIZE * 2:
					player.hints.generate_hint(Color.WHITE, new_position - Vector2(level_info.TILE_SIZE/2, level_info.TILE_SIZE/2))
					if Input.is_action_just_pressed("select"):
						player.pickup(direction)

func set_state(state : State):
	player = get_tree().get_first_node_in_group("player")
	player.hints.clear_hints()
	current_state = state
