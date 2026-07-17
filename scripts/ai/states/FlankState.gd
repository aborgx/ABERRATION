extends Node
## Flank: move to a lateral position relative to the player.
## Then attack from the side.

var enemy: EnemyBase
var flank_target: Vector3
var reached: bool = false

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	flank_target = enemy.get_flank_point()
	reached = false
	enemy.play_anim("run")

func exit() -> void:
	pass

func process(delta: float) -> void:
	if not enemy.player:
		enemy.fsm.transition("patrol")
		return
	
	if reached:
		enemy.fsm.transition("attack")
	elif enemy.player_distance < enemy.attack_range:
		enemy.fsm.transition("attack")

func physics_process(delta: float) -> void:
	if enemy.global_position.distance_to(flank_target) < 2.0:
		reached = true
		enemy.velocity = Vector3.ZERO
		return
	
	var nav = enemy.nav_to(flank_target)
	if nav.length() > 0:
		enemy.velocity.x = nav.x
		enemy.velocity.z = nav.z
	else:
		enemy.move_toward(flank_target, enemy.run_speed)
