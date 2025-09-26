extends Enemy

func generate_hints():
	for direction in [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1)]:
		if level.map.get_cell_atlas_coords(level.map.local_to_map(global_position) + direction) != Vector2i(1, 0):
			for l in range(1, info.action["range"] + 1):
				level.hints.generate_hint(Color.RED, global_position + 1 * level.info.TILE_SIZE)

func choose_action():
	var player_visible = is_player_visible()
	if player_visible:
		last_player_position = player.global_position
	var displacement = abs(player.global_position - global_position)
	if player_visible and info.energy >= info.action["cost"] and ((displacement.x == 0 and displacement.y <= info.action["range"]) or (displacement.y == 0 and displacement.x <= info.action["range"])):
		take_action(attack, 1)
	elif info.energy >= info.weight and not (displacement.x == 0 or displacement.y == 0):
		take_action(move.bind(1, ["enemy", "pickup"]), 0.3)
	else:
		emit_signal("end_turn")
