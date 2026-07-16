extends Node3D

func _ready() -> void:
	print("TestAI: Ready — AI integration test")
	
	var enemy_types = [
		"EnemyInfantry", "EnemyShield", "EnemyFlamethrower",
		"EnemySniper", "EnemyEngineer", "EnemyMedic",
		"EnemyHeavy", "EnemyDrone", "EnemyRobot", "EnemyElite",
		"BossJuggernaut", "BossAssaultRobot", "BossPredatorHelicopter"
	]
	
	for type_name in enemy_types:
		var enemy = get_node_or_null(type_name)
		if enemy:
			print("TestAI: Found ", type_name)
		else:
			print("TestAI: MISSING ", type_name)
	
	var director = get_tree().get_first_node_in_group("director")
	if director:
		print("TestAI: Director found")
	else:
		print("TestAI: Director MISSING")
	
	var pool = get_tree().get_first_node_in_group("pool_manager")
	if pool:
		print("TestAI: PoolManager found")
	else:
		print("TestAI: PoolManager MISSING")
	
	var spawn = get_tree().get_first_node_in_group("spawn_manager")
	if spawn:
		print("TestAI: SpawnManager found")
	else:
		print("TestAI: SpawnManager MISSING")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_print_all_enemy_states()

func _print_all_enemy_states() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("get_fsm_state"):
			print(enemy.name, ": ", enemy.get_fsm_state())