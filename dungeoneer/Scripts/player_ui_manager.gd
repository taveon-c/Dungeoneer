extends CanvasLayer
enum State {
	NONE,
	MOVE,
	ATTACK,
	PICKUP,
	DROP
}

@export var player : Node2D
@export var level : Node2D
@export var player_info_label : Label
@export var select_info_label : Label
@export var current_state: State

func _ready() -> void:
	player.info.connect("info_changed", on_info_changed)

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if InputMap.event_is_action(event, "enter"):
			match current_state:
				State.MOVE:
					var select_position = get_select_position()
					var options = get_move_options()
					if select_position in options:
						player.move(select_position)
				State.ATTACK:
					var selection_position = get_mouse_cell_position()
					var options = player.info.weapon.get_options(level)
					if selection_position in options and player.info.energy >= player.info.weapon.cost:
						player.attack(selection_position)
				State.PICKUP:
					var selection_position = get_select_position()
					var options = get_pickup_options()
					if selection_position in options:
						player.pickup(selection_position)
				State.DROP:
					if player.info.weapon.name != "Fists":
						var selection_position = get_select_position()
						var options = get_drop_options()
						if selection_position in options:
							player.drop(selection_position)
		elif event is InputEventKey:
			match event.keycode:
				KEY_1:
					on_state_pressed(State.MOVE)
				KEY_2:
					on_state_pressed(State.ATTACK)
				KEY_3:
					on_state_pressed(State.PICKUP)
				KEY_4:
					on_state_pressed(State.DROP)
				KEY_E:
					if current_state == 0:
						on_end_pressed()
					else:
						on_exit_state_pressed()

func _process(delta: float) -> void:
	update_markers()

func get_drop_options():
	var options = []
	var enemies = get_tree().get_nodes_in_group("enemy")
	var pickups = get_tree().get_nodes_in_group("pickup")
	for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
		var neighbor_pos = player.global_position + Vector2(direction * level.info.TILE_SIZE)
		var neighbor_cell = level.map.local_to_map(player.global_position) + direction
		if level.in_bounds(neighbor_cell) and level.map.get_cell_atlas_coords(neighbor_cell) == Vector2i(0, 0):
			var is_option = true
			for enemy in enemies:
				if enemy.global_position == neighbor_pos:
					is_option = false
					break
			if not is_option:
				continue
			for pickup in pickups:
				if pickup.global_position == neighbor_pos:
					is_option = false
					break
			if is_option:
				options.append(neighbor_pos)
	return options

func get_pickup_options():
	var options = []
	var pickups = get_tree().get_nodes_in_group("pickup")
	for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
		var neighbor_pos = player.global_position + Vector2(direction * level.info.TILE_SIZE)
		var neighbor_cell = level.map.local_to_map(player.global_position) + direction
		if level.in_bounds(neighbor_cell) and level.map.get_cell_atlas_coords(neighbor_cell) == Vector2i(0, 0):
			for pickup in pickups:
				if pickup.global_position == neighbor_pos:
					options.append(neighbor_pos)
	return options

func get_pickup_hints():
	var hints = []
	var pickups = get_tree().get_nodes_in_group("pickup")
	for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
		var neighbor_pos = player.global_position + Vector2(direction * level.info.TILE_SIZE)
		var neighbor_cell = level.map.local_to_map(player.global_position) + direction
		if level.in_bounds(neighbor_cell) and level.map.get_cell_atlas_coords(neighbor_cell) == Vector2i(0, 0):
			var is_hint = true
			for pickup in pickups:
				if pickup.global_position == neighbor_pos:
					is_hint = false
			if is_hint:
				hints.append(neighbor_pos)
	return hints

func get_move_options():
	var options = []
	if player.info.energy > 0:
		var enemies = get_tree().get_nodes_in_group("enemy")
		var pickups = get_tree().get_nodes_in_group("pickup")
		for direction in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
			var neighbor_pos = player.global_position + Vector2(direction * level.info.TILE_SIZE)
			var neighbor_cell = level.map.local_to_map(player.global_position) + direction
			if level.in_bounds(neighbor_cell) and level.map.get_cell_atlas_coords(neighbor_cell) == Vector2i(0, 0):
				var is_option = true
				for enemy in enemies:
					if enemy.global_position == neighbor_pos:
						is_option = false
						break
				if not is_option:
					continue
				for pickup in pickups:
					if pickup.global_position == neighbor_pos:
						is_option = false
						break
				if is_option:
					options.append(neighbor_pos)
	return options

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

func on_state_pressed(state : State):
	$EndTurnGuide.visible = false
	$ExitGuide.visible = true
	player = get_tree().get_first_node_in_group("player")
	current_state = state
	update_markers()

func get_mouse_cell_position():
	return level.map.map_to_local(level.map.local_to_map(level.get_global_mouse_position()))

func get_select_position():
	var key_x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	var key_y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var key_input = Vector2(key_x, key_y)
	return player.global_position + key_input * level.info.TILE_SIZE

func update_markers():
	match current_state:
		State.NONE:
			var selection_position = get_mouse_cell_position()
			select_info_label.text = ""
			var mouse_cell = level.map.local_to_map(selection_position)
			var non_visible_cells = level.visibility.get_used_cells()
			if level.visibility.get_cell_atlas_coords(mouse_cell) == Vector2i(-1, -1) and level.map.get_cell_atlas_coords(mouse_cell) == Vector2i(0, 0):
				level.markers.set_select(selection_position, Color.WHITE)
				var pickups = get_tree().get_nodes_in_group("pickup")
				var enemies = get_tree().get_nodes_in_group("enemy")
				for pickup in pickups:
					if pickup.global_position == selection_position:
						match pickup.item.type:
							0:
								select_info_label.text = pickup.item.print()
							1:
								select_info_label.text = "Armor\narmor: 2\nweight: 1"
						return
				for enemy in enemies:
					if enemy.global_position == selection_position:
						select_info_label.text = enemy.info.print()
						enemy.generate_markers(level)
						return
			else:
				level.markers.clear_select()
			if level.markers.options.size() > 0 or level.markers.hints.size() > 0:
				level.markers.clear()
		State.MOVE:
			var options = get_move_options()
			var select_pos = get_select_position()
			level.markers.set_markers(Color.DEEP_SKY_BLUE, options)
			if select_pos in options:
				level.markers.set_select(select_pos, Color.DEEP_SKY_BLUE)
			else:
				level.markers.clear_select()
		State.PICKUP:
			var options = get_pickup_options()
			var hints = get_pickup_hints()
			level.markers.set_markers(Color.WHITE, options, hints)
			var selection_position = get_select_position()
			if selection_position in options:
				level.markers.set_select(selection_position, Color.WHITE)
			else:
				level.markers.clear_select()
		State.ATTACK:
			if player.info.energy >= player.info.weapon.cost:
				var options = player.info.weapon.get_options(level)
				var new_hints = player.info.weapon.get_hints(level)
				level.markers.set_markers(Color.RED, options, new_hints)
				var selection_position = get_mouse_cell_position()
				if selection_position in options:
					level.markers.set_select(selection_position, Color.RED)
				else:
					level.markers.clear_select()
			else:
				level.markers.set_markers(Color.RED, [], [])
				level.markers.clear_select()
		State.DROP:
			if player.info.weapon.name != "Fists":
				var options = get_drop_options()
				level.markers.set_markers(Color.WHITE, options)
				var selection_position = get_select_position()
				if selection_position in options:
					level.markers.set_select(selection_position, Color.WHITE)
				else:
					level.markers.clear_select()
			else:
				level.markers.set_markers(Color.WHITE, [], [])
				level.markers.clear_select()

func on_exit_state_pressed():
	level.markers.clear()
	$ExitGuide.visible = false
	$EndTurnGuide.visible = true
	current_state = State.NONE
