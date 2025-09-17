extends Enemy

func _init():
	actions = [attack, move]

func attack():
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0]
	
	var displacement = player.global_position - global_position
	var direction = displacement.sign()
	if info.energy >= info.action["cost"] and abs(displacement.x) <= 16 and abs(displacement.y) <= 16:
		player.info.spend_energy(info.action["stun"])
		player.info.damage(
			{
				"cut" : 0,
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
