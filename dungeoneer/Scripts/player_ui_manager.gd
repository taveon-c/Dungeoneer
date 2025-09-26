extends CanvasLayer
enum State {
	NONE,
	MOVE,
	ATTACK,
	PICKUP
}

@export var player : Node2D
@export var level : Node2D
@export var player_info_label : Label
@export var select_info_label : Label
@export var end_turn_button : Button
@export var current_state: State
var select_enemy : Enemy

func _ready() -> void:
	player.info.connect("info_changed", on_info_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and current_state == State.NONE:
		select_info_label.text = ""
		var mouse_position = get_parent().get_global_mouse_position()
		var mouse_cell = level.map.local_to_map(mouse_position)
		var non_visible_cells = get_parent().visibility.get_used_cells()
		if not mouse_cell in non_visible_cells:
			var mouse_cell_position = level.map.map_to_local(mouse_cell)
			var pickups = get_tree().get_nodes_in_group("pickup")
			var enemies = get_tree().get_nodes_in_group("enemy")
			for pickup in pickups:
				if pickup.global_position == mouse_cell_position:
					match pickup.item.type:
						0:
							select_info_label.text = pickup.item.print()
						1:
							select_info_label.text = "armor"
					return
			for enemy in enemies:
				if enemy.global_position == mouse_cell_position:
					select_info_label.text = enemy.info.print()
					if enemy != select_enemy:
						level.hints.clear_hints()
						select_enemy = enemy
						enemy.generate_hints()
					return
		select_enemy = null
		level.hints.clear_hints()

func _physics_process(delta: float) -> void:
	match current_state:
		State.MOVE:
			level.hints.clear_hints()
			level.set_astar_obstacles(2, ["enemy", "item"])
			if player.info.energy >= player.info.get_weight():
				var options = []
				for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
					var neighbor = level.map.local_to_map(player.global_position) + direction
					if level.astar_layers[2].is_in_boundsv(neighbor) and not level.astar_layers[2].is_point_solid(neighbor):
						options.append(neighbor)
						level.hints.generate_hint(Color.DEEP_SKY_BLUE, level.map.map_to_local(neighbor))
				level.clear_astar_obstacles(2, ["enemy", "item"])
				
				var mouse_coords = level.map.local_to_map(player.get_global_mouse_position())
				if mouse_coords in options:
					var new_position = level.map.map_to_local(mouse_coords)
					level.hints.generate_hint(Color.DEEP_SKY_BLUE, new_position)
					if Input.is_action_just_pressed("select"):
						player.move(new_position)
		State.ATTACK:
			level.hints.clear_hints()
			if player.info.weapon.cost <= player.info.energy:
				var mouse_position : Vector2 = player.get_global_mouse_position()
				var action_info = player.info.weapon.action(mouse_position, player)
				for hint in action_info["hints"]:
					level.hints.generate_hint(Color.RED, hint)
				if mouse_position.distance_to(player.global_position) < (player.info.weapon.range + 1) * level.info.TILE_SIZE:
					for space in action_info["spaces"]:
						level.hints.generate_hint(Color.RED, space)
					if Input.is_action_just_pressed("select"):
						player.attack(action_info)
		State.PICKUP:
			level.hints.clear_hints()
			level.set_astar_obstacles(2, ["enemy"])
			if player.info.energy >= player.info.weight:
				var options = []
				for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
					var neighbor = level.map.local_to_map(player.global_position) + direction
					if level.astar_layers[2].is_in_boundsv(neighbor) and not level.astar_layers[2].is_point_solid(neighbor):
						options.append(neighbor)
						level.hints.generate_hint(Color.WHITE, level.map.map_to_local(neighbor))
				
				var mouse_coords = level.map.local_to_map(player.get_global_mouse_position())
				if mouse_coords in options:
					var new_position = level.map.map_to_local(mouse_coords)
					level.hints.generate_hint(Color.WHITE, new_position)
					if Input.is_action_just_pressed("select"):
						player.pickup(new_position)
			level.clear_astar_obstacles(2, ["enemy"])

func on_info_changed():
	player_info_label.text = player.info.print()

func on_end_pressed():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		player.info.regen_energy()
	else:
		visible = false
		level._on_turn_end()

func on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func set_state(state : State):
	player = get_tree().get_first_node_in_group("player")
	level.hints.clear_hints()
	current_state = state
