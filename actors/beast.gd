extends Area2D
class_name Beast

@export var character_sheet: CharacterSheet
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var target

func _ready():
	# Connect the body_entered signal to a function
	body_entered.connect(_on_body_entered)
	navigation_agent.target_reached.connect(_on_target_reached)

func _physics_process(delta):
	if target:
		navigation_agent.target_position = target.global_position
		if global_position.distance_to(target.global_position) < 50:
			CombatManager.handle_combat(self, target)
			target = null

	if navigation_agent.is_navigation_finished():
		return

	var next_path_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	global_position += direction * character_sheet.move_speed * delta


func _on_body_entered(body):
	if body is Player or body is Packer or body is RecruitableCrew:
		target = body

func _on_target_reached():
	if target:
		CombatManager.handle_combat(self, target)
		target = null

func die():
	queue_free()

func _on_combat_ended(result):
	if result["winner"] == character_sheet:
		if result["loser"] is Player:
			# Player lost, apply penalty
			result["loser"].pacs = max(0, result["loser"].pacs - 20)
		else:
			# Beast defeated a packer or crew, get a stat boost
			var stat_boost = randi_range(1, 10)
			var stat_to_boost = ["health", "attack", "defense"].pick_random()
			character_sheet.set(stat_to_boost, character_sheet.get(stat_to_boost) + stat_boost)
			print(character_sheet.name + " defeated " + result["loser"].name + " and got a " + str(stat_boost) + " boost to " + stat_to_boost + "!")
	else:
		if result["winner"] is Player:
			# Player won, get rewards
			var dropped_component = ComponentGenerator.generate_component()
			result["winner"].add_to_inventory(dropped_component.component_name, 1)
			result["winner"].pacs += character_sheet.pacs

		die()
