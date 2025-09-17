extends Enemy

func _init() -> void:
	actions = [attack, move]

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if info.energy >= info.action["cost"] and player.global_position.distance_to(self.global_position) < info.action["range"] * 16:
		player.info.damage(
			{
				"cut" : info.action["cut"],
				"blunt" : info.action["blunt"]
			}
		)
		info.spend_energy(info.action["cost"])
	else:
		move()

func move():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	if info.energy >= info.weight:
		set_astar_obstacles(["enemy", "player", "weapon"])
		var self_id = map.local_to_map(self.global_position)
		var player_id = map.local_to_map(player.global_position)
		var path = get_parent().get_parent().astar_layers[2].get_point_path(self_id, player_id, true)
		clear_astar_obstacles(["enemy", "player", "weapon"])
		if path.size() > 1:
			self.global_position = path[1]
			info.spend_energy(info.weight)
		else:
			emit_end_turn()
	else:
		emit_end_turn()
