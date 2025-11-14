extends Node

func handle_combat(actor1, actor2):
	var actor1_sheet = actor1.character_sheet
	var actor2_sheet = actor2.character_sheet

	var actor1_hp = actor1_sheet.health
	var actor2_hp = actor2_sheet.health

	var combat_log = "--- Combat Begins! ---\n"
	combat_log += actor1_sheet.name + " vs. " + actor2_sheet.name + "\n"

	while actor1_hp > 0 and actor2_hp > 0:
		# Actor 1's turn
		if _perform_attack(actor1_sheet, actor2_sheet, actor1_hp, actor2_hp, combat_log):
			actor2_hp -= 1
		if actor2_hp <= 0:
			break

		# Actor 2's turn
		if _perform_attack(actor2_sheet, actor1_sheet, actor2_hp, actor1_hp, combat_log):
			actor1_hp -= 1
		if actor1_hp <= 0:
			break

	var winner = actor1_sheet if actor1_hp > 0 else actor2_sheet
	var loser = actor2_sheet if actor1_hp > 0 else actor1_sheet

	combat_log += "--- Combat Ends! ---\n"
	combat_log += winner.name + " is victorious!\n"

	GameEvents.combat_ended.emit(combat_log)

	return {
		"winner": winner,
		"loser": loser
	}


func _perform_attack(attacker_sheet, defender_sheet, attacker_hp, defender_hp, combat_log):
	var attack_roll = randi_range(0, 50) + attacker_sheet.attack
	var defense_roll = randi_range(0, 50) + defender_sheet.defense

	if attack_roll > defense_roll:
		combat_log += attacker_sheet.name + " hits! " + defender_sheet.name + " HP: " + str(defender_hp - 1) + "\n"
		return true
	else:
		combat_log += attacker_sheet.name + " misses!\n"
		return false
