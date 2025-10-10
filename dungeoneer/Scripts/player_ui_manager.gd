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
@export var end_turn_button : Button
@export var current_state: State
@onready var action_container: HBoxContainer = $"Action Container"
@onready var exit_state_button : Button = $"Exit"

func _ready() -> void:
	action_container.get_child(3).disabled = true
	player.info.connect("info_changed", on_info_changed)

func _input(event: InputEvent) -> void:
	if InputMap.event_is_action(event, "select") and event.is_pressed():
		match current_state:
			State.MOVE:
				var mouse_position = level.map.map_to_local(level.map.local_to_map(level.get_global_mouse_position()))
				var options = get_move_options()
				if mouse_position in options:
					player.move(mouse_position)
			State.ATTACK:
				var mouse_pos = get_mouse_cell_position()
				var options = player.info.weapon.get_options(level)
				if mouse_pos in options:
					player.attack(mouse_pos)
			State.PICKUP:
				var mouse_position = level.map.map_to_local(level.map.local_to_map(get_parent().get_global_mouse_position()))
				var options = get_pickup_options()
				if mouse_position in options:
					player.pickup(mouse_position)
					action_container.get_child(3).disabled = false
			State.DROP:
				if player.info.weapon.name != "Fists":
					var mouse_position = level.map.map_to_local(level.map.local_to_map(get_parent().get_global_mouse_position()))
					var options = get_drop_options()
					if mouse_position in options:
						player.drop(mouse_position)
						action_container.get_child(3).disabled = true

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
	action_container.visible = false
	end_turn_button.visible = false
	exit_state_button.visible = true
	player = get_tree().get_first_node_in_group("player")
	current_state = state
	update_markers()

func get_mouse_cell_position():
	return level.map.map_to_local(level.map.local_to_map(level.get_global_mouse_position()))

func update_markers():
	match current_state:
		State.NONE:
			var mouse_position = get_mouse_cell_position()
			select_info_label.text = ""
			var mouse_cell = level.map.local_to_map(mouse_position)
			var non_visible_cells = level.visibility.get_used_cells()
			if level.visibility.get_cell_atlas_coords(mouse_cell) == Vector2i(-1, -1) and level.map.get_cell_atlas_coords(mouse_cell) == Vector2i(0, 0):
				level.markers.set_select(mouse_position, Color.WHITE)
				var pickups = get_tree().get_nodes_in_group("pickup")
				var enemies = get_tree().get_nodes_in_group("enemy")
				for pickup in pickups:
					if pickup.global_position == mouse_position:
						match pickup.item.type:
							0:
								select_info_label.text = pickup.item.print()
							1:
								select_info_label.text = "Armor\narmor: 2\nweight: 1"
						return
				for enemy in enemies:
					if enemy.global_position == mouse_position:
						select_info_label.text = enemy.info.print()
						enemy.generate_markers(level)
						return
			else:
				level.markers.clear_select()
			if level.markers.options.size() > 0 or level.markers.hints.size() > 0:
				level.markers.clear()
		State.MOVE:
			var options = get_move_options()
			var mouse_pos = get_mouse_cell_position()
			level.markers.set_markers(Color.DEEP_SKY_BLUE, options)
			if mouse_pos in options:
				level.markers.set_select(mouse_pos, Color.DEEP_SKY_BLUE)
			else:
				level.markers.clear_select()
		State.PICKUP:
			var options = get_pickup_options()
			var hints = get_pickup_hints()
			level.markers.set_markers(Color.WHITE, options, hints)
			var mouse_pos = get_mouse_cell_position()
			if mouse_pos in options:
				level.markers.set_select(mouse_pos, Color.WHITE)
			else:
				level.markers.clear_select()
		State.ATTACK:
			var options = player.info.weapon.get_options(level)
			var new_hints = player.info.weapon.get_hints(level)
			level.markers.set_markers(Color.RED, options, new_hints)
			var mouse_pos = get_mouse_cell_position()
			if mouse_pos in options:
				level.markers.set_select(mouse_pos, Color.RED)
			else:
				level.markers.clear_select()
		State.DROP:
			var options = get_drop_options()
			level.markers.set_markers(Color.WHITE, options)
			var mouse_pos = get_mouse_cell_position()
			if mouse_pos in options:
				level.markers.set_select(mouse_pos, Color.WHITE)
			else:
				level.markers.clear_select()

func on_exit_state_pressed():
	level.markers.clear()
	exit_state_button.visible = false
	action_container.visible = true
	end_turn_button.visible = true
	current_state = State.NONE
