extends CharacterBody2D
class_name RecruitableCrew

@export var character_sheet: CharacterSheet
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var target_position
var target_beast

func _ready():
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	navigation_agent.avoidance_mask = 1
	navigation_agent.connect("target_reached", Callable(self, "_on_target_reached"))

	# Start the wandering behavior
	_find_new_wander_target()

func _physics_process(_delta):
	if target_beast:
		navigation_agent.target_position = target_beast.global_position
		if global_position.distance_to(target_beast.global_position) < 50:
			CombatManager.handle_combat(self, target_beast)
			target_beast = null

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_path_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	velocity = direction * character_sheet.move_speed
	move_and_slide()

	_find_beast_target()

func _find_new_wander_target():
	# Wander to a random point on the map
	target_position = Vector2(randf_range(0, 1152), randf_range(0, 648))
	navigation_agent.target_position = target_position

func _on_target_reached():
	# Arrived at wander position, find a new one
	_find_new_wander_target()

func _find_beast_target():
	var beasts = get_tree().get_nodes_in_group("beasts")
	var closest_beast = null
	var min_distance = 200 # Agro radius

	for beast in beasts:
		var distance = global_position.distance_to(beast.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_beast = beast

	if closest_beast:
		target_beast = closest_beast

func get_recruitment_cost() -> int:
	var total_stats = character_sheet.health + character_sheet.attack + character_sheet.defense
	return total_stats * 10 # 10 pacs per stat point

func die():
	queue_free()

func _on_combat_ended(result):
	if result["winner"] == character_sheet:
		# Crew defeated a beast, get a stat boost
		var stat_boost = randi_range(1, 10)
		var stat_to_boost = ["health", "attack", "defense"].pick_random()
		character_sheet.set(stat_to_boost, character_sheet.get(stat_to_boost) + stat_boost)
		print(character_sheet.character_name + " defeated " + result["loser"].character_name + " and got a " + str(stat_boost) + " boost to " + stat_to_boost + "!")

		# Find a new wander target after a fight
		_find_new_wander_target()
	else:
		# Crew was defeated
		die()
