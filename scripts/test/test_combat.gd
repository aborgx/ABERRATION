extends Node3D

func _ready() -> void:
	print("TestCombat: Ready — manual combat testing")
	
	# Auto-spawn more enemies for stress test
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_spawn_enemy)
	add_child(timer)

func _spawn_enemy() -> void:
	var enemy = DummyEnemy.new()
	enemy.global_position = Vector3(randf_range(-15, 15), 1, randf_range(-15, 15))
	add_child(enemy)