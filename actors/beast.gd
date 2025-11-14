extends Area2D
class_name Beast

# --- Combat Stats ---
@export var character_sheet: CharacterSheet

func _ready():
	# Connect the body_entered signal to a function
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body that entered is the player
	if body is Player and body.character_sheet and character_sheet:
		# --- Run Combat Simulation ---
		var player_hp = body.character_sheet.health
		var beast_hp = character_sheet.health
		var combat_log = "--- Combat Begins! ---\n"

		while player_hp > 0 and beast_hp > 0:
			# Player's turn
			var player_attack_roll = randi_range(0, 50) + body.character_sheet.attack
			var beast_defense_roll = randi_range(0, 50) + character_sheet.defense
			if player_attack_roll > beast_defense_roll:
				beast_hp -= 1
				combat_log += "Player hits! Beast HP: " + str(beast_hp) + "\n"
			else:
				combat_log += "Player misses!\n"

			if beast_hp <= 0:
				break

			# Beast's turn
			var beast_attack_roll = randi_range(0, 50) + character_sheet.attack
			var player_defense_roll = randi_range(0, 50) + body.character_sheet.defense
			if beast_attack_roll > player_defense_roll:
				player_hp -= 1
				combat_log += "Beast hits! Player HP: " + str(player_hp) + "\n"
			else:
				combat_log += "Beast misses!\n"

		# --- Determine Winner & Rewards ---
		var combat_result_text = ""
		if player_hp > 0:
			var dropped_component = ComponentGenerator.generate_component()
			body.character_sheet.inventory.append(dropped_component)
			combat_result_text = "You won! You receive " + str(character_sheet.pacs) + " pacs and found a " + dropped_component.component_name + "!"
			body.character_sheet.pacs += character_sheet.pacs
		else:
			var penalty = 20
			combat_result_text = "You lost! You lost " + str(penalty) + " pacs."
			body.character_sheet.pacs = max(0, body.character_sheet.pacs - penalty)

		combat_log += "--- Combat Ends! ---\n" + combat_result_text

		# Emit the combat ended signal with the combat log
		GameEvents.combat_ended.emit(combat_log)

		# For simplicity, the beast removes itself after the encounter
		queue_free()
