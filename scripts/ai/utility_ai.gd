class_name UtilityAI
extends Node

func calculate_scores(enemy: Dictionary, player: Dictionary = {}) -> Dictionary:
	var scores = {}
	
	scores["attack"] = calculate_attack_score(enemy)
	scores["cover"] = calculate_cover_score(enemy)
	scores["flank"] = calculate_flank_score(enemy, player)
	scores["retreat"] = calculate_retreat_score(enemy)
	scores["call_help"] = calculate_help_score(enemy)
	
	return scores

func calculate_attack_score(enemy: Dictionary) -> float:
	var score = 0.0
	
	# Distance factor
	var dist = enemy.player_distance
	if dist < 5.0:
		score += 30.0
	elif dist < 10.0:
		score += 20.0
	elif dist < 20.0:
		score += 10.0
	
	# Health factor
	if enemy.health > 80:
		score += 20.0
	elif enemy.health > 50:
		score += 10.0
	
	# Ammo factor
	if enemy.ammo > 50:
		score += 15.0
	elif enemy.ammo > 20:
		score += 10.0
	
	# Cover factor
	if enemy.has_cover:
		score += 10.0
	
	return score

func calculate_cover_score(enemy: Dictionary) -> float:
	var score = 0.0
	
	if enemy.health < 30:
		score += 40.0
	elif enemy.health < 60:
		score += 20.0
	
	if enemy.is_under_fire:
		score += 30.0
	
	if enemy.player_distance < 5.0:
		score += 20.0
	
	return score

func calculate_flank_score(enemy: Dictionary, player: Dictionary) -> float:
	var score = 0.0
	
	if not player.has_cover:
		score += 25.0
	
	if enemy.has_flank_position:
		score += 20.0
	
	if enemy.allies_attacking_front > 2:
		score += 15.0
	
	return score

func calculate_retreat_score(enemy: Dictionary) -> float:
	var score = 0.0
	
	if enemy.health < 20:
		score += 50.0
	elif enemy.health < 40:
		score += 30.0
	
	if enemy.ammo < 5:
		score += 25.0
	
	return score

func calculate_help_score(enemy: Dictionary) -> float:
	var score = 0.0
	
	if enemy.health < 50:
		score += 20.0
	
	if enemy.allies_nearby < 3:
		score += 15.0
	
	return score

func get_best_action(scores: Dictionary) -> String:
	var best_action = "idle"
	var best_score = -1.0
	
	for action in scores:
		if scores[action] > best_score:
			best_score = scores[action]
			best_action = action
	
	return best_action