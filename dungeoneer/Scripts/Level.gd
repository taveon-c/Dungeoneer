extends Node2D
var turn : bool = false
@onready var timer : Timer = $Timer
@onready var Player = $Player
@onready var Path = $Path
@onready var Attack = $Attack
@onready var Action  =$Action

func _on_submit_pressed() -> void:
	Action.visible = false
	timer.start()

func _on_timer_timeout() -> void:
	if Path.get_child_count() > 0:
		var next_step = Path.get_child(0)
		Player.global_position = next_step.global_position
		Path.remove_child(next_step)
		next_step.queue_free()
	else:
		if Attack.get_child_count() > 0:
			var next_attack = Attack.get_child(0)
			Attack.remove_child(next_attack)
			next_attack.queue_free()
		else:
			Action.visible = true
			timer.stop()
