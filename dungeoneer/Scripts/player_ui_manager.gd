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
@export var level : Node2D
@export var current_state: State
var select_enemy : Enemy

func _input(event: InputEvent) -> void:
	if select_enemy:
		select_enemy.hints.visible = false
		select_enemy = null
	if event is InputEventMouseMotion and current_state == State.NONE:
		select_info_label.clear_info()
		var mouse_position = get_parent().get_global_mouse_position()
		var mouse_cell = level.map.local_to_map(mouse_position)
		var non_visible_cells = get_parent().visibility.get_used_cells()
		if not mouse_cell in non_visible_cells:
			var mouse_cell_position = level.map.map_to_local(mouse_cell)
			var items = get_tree().get_nodes_in_group("item")
			var enemies = get_tree().get_nodes_in_group("enemy")
			for item in items:
				if item.global_position == mouse_cell_position:
					select_info_label.display_info(item.item)
					return
			for enemy in enemies:
				if enemy.global_position == mouse_cell_position:
					select_info_label.display_info(enemy.info)
					enemy.hints.visible = true
					select_enemy = enemy
					return

func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE:
			player.hints.clear_hints()
			level.set_astar_obstacles(2, ["enemy", "item"])
			if player.info.energy >= player.info.weight:
				var options = []
				for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
					var neighbor = level.map.local_to_map(player.global_position) + direction
					if level.astar_layers[2].is_in_boundsv(neighbor) and not level.astar_layers[2].is_point_solid(neighbor):
						options.append(neighbor)
						player.hints.generate_hint(Color.DEEP_SKY_BLUE, level.map.map_to_local(neighbor))
				
				var mouse_coords = level.map.local_to_map(player.get_global_mouse_position())
				if mouse_coords in options:
					var new_position = level.map.map_to_local(mouse_coords)
					player.hints.generate_hint(Color.DEEP_SKY_BLUE, new_position)
					if Input.is_action_just_pressed("select"):
						player.move(new_position)
			level.clear_astar_obstacles(2, ["enemy", "item"])
		State.ATTACK:
			player.hints.clear_hints()
			if player.info.weapon.cost <= player.info.energy:
				var mouse_position : Vector2 = player.get_global_mouse_position()
				var action_info = player.info.weapon.action(mouse_position, player)
				for hint in action_info["hints"]:
					player.hints.generate_hint(Color.RED, hint)
				if mouse_position.distance_to(player.global_position) < (player.info.weapon.range + 1) * level.info.TILE_SIZE:
					for space in action_info["spaces"]:
						player.hints.generate_hint(Color.RED, space)
					if Input.is_action_just_pressed("select"):
						player.attack(action_info)
		State.PICKUP:
			player.hints.clear_hints()
			level.set_astar_obstacles(2, ["enemy"])
			if player.info.energy >= player.info.weight:
				var options = []
				for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
					var neighbor = level.map.local_to_map(player.global_position) + direction
					if level.astar_layers[2].is_in_boundsv(neighbor) and not level.astar_layers[2].is_point_solid(neighbor):
						options.append(neighbor)
						player.hints.generate_hint(Color.WHITE, level.map.map_to_local(neighbor))
				
				var mouse_coords = level.map.local_to_map(player.get_global_mouse_position())
				if mouse_coords in options:
					var new_position = level.map.map_to_local(mouse_coords)
					player.hints.generate_hint(Color.WHITE, new_position)
					if Input.is_action_just_pressed("select"):
						player.pickup(new_position)
			level.clear_astar_obstacles(2, ["enemy"])

func set_state(state : State):
	player = get_tree().get_first_node_in_group("player")
	player.hints.clear_hints()
	current_state = state
