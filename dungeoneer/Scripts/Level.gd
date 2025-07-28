extends Node2D
var turn : int = 0
@onready var timer : Timer = $Timer
@onready var Player = $Player
@onready var Enemies = $Enemies
@onready var Action  =$Action
@onready var Hints = $Hints
@onready var Info = $Info
var is_moving = false
var is_attack = false

func _on_submit_pressed() -> void:
	for enemy in Enemies.get_children():
		enemy.generate_path()
		enemy.generate_attack()
	
	Action.visible = false
	Info.update_points()
	
	generate_hints()
	
	timer.start()

func generate_hints():
	Hints.clear_hints()
	
	for step in Player.path:
		Hints.generate_hint(Color.DEEP_SKY_BLUE, step)
	for space in Player.attack:
		if Player.path.size() > 0:
			Hints.generate_hint(Color.RED, space + Player.path.back())
		else:
			Hints.generate_hint(Color.RED, space + Player.global_position)
	
	for enemy in Enemies.get_children():
		for step in enemy.path:
			Hints.generate_hint(Color.CORAL, step)
		for space in enemy.attack:
			Hints.generate_hint(Color.PURPLE, space)

func _on_timer_timeout() -> void:
	is_moving = false
	if Player.path.size() > 0:
		Player.move_points -= 1
		Player.global_position = Player.path.pop_front()
		if Player.path.size() > 0:
			is_moving = true
	for enemy in Enemies.get_children():
		if enemy.path.size() > 0:
			enemy.move_points -= 1
			enemy.global_position = enemy.path.pop_front()
			if enemy.path.size() > 0:
				is_moving = true
	if is_moving:
		generate_hints()
	if not is_moving and not is_attack:
		generate_hints()
		is_attack = true
	elif not is_moving and is_attack:
		timer.stop()
		turn += 1
		is_attack = false
		
		for enemy in Enemies.get_children():
			for space in enemy.attack:
				if space == Player.global_position:
					Player.health -= enemy.attack_cost
			
			for space in Player.attack:
				if space + Player.global_position == enemy.global_position:
					enemy.health -= Player.attack_cost
			enemy.turn()
		
		Player.turn()
		
		Hints.clear_hints()
		Info.update_points()
		Info.update_turn()
		Action.visible = true
	
