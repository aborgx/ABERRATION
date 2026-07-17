extends Node
## Cover: move toward cover and stay there to recover.
## Uses "cover_points" group nodes placed in the level.

var enemy: EnemyBase
var cover_node: Node3D = null

func setup(e: EnemyBase) -> void:
	enemy = e

func enter() -> void:
	cover_node = _find_nearest_cover()
	enemy.play_anim("crouch_run" if enemy.anim_player and enemy.anim_player.has_animation("crouch_run") else "run")

func exit() -> void:
	pass

func process(delta: float) -> void:
	if not cover_node:
		enemy.fsm.transition("patrol")
		return
	
	var dist = enemy.global_position.distance_to(cover_node.global_position)
	if dist < 2.0:
		# At cover — rest then re-engage
		if not enemy.is_under_fire and enemy.health > enemy.max_health * 0.3:
			enemy.fsm.transition("engage")
	elif enemy.player_distance < enemy.attack_range * 0.8:
		# Player got too close — stop hiding
		enemy.fsm.transition("attack")

func physics_process(delta: float) -> void:
	if not cover_node:
		return
	var dist = enemy.global_position.distance_to(cover_node.global_position)
	if dist < 2.0:
		enemy.velocity = Vector3.ZERO
		return
	enemy.move_toward(cover_node.global_position, enemy.run_speed)

func _find_nearest_cover() -> Node3D:
	var covers = enemy.get_tree().get_nodes_in_group("cover_points")
	if covers.is_empty():
		return null
	var nearest = covers[0]
	var nearest_dist = enemy.global_position.distance_to(nearest.global_position)
	for c in covers:
		var d = enemy.global_position.distance_to(c.global_position)
		if d < nearest_dist:
			nearest = c
			nearest_dist = d
	return nearest
