extends Node

const COMPONENT_TYPES = ["Weapon", "Armor", "Engine", "Scanner", "Cargo"]
const STAT_NAMES = {
	"health": "Vitality",
	"attack": "Power",
	"defense": "Fortitude",
	"move_speed": "Speed"
}

# --- Weighted Stats ---
# Define which stats are more likely to be positive or negative for each component type.
const WEIGHTED_STATS = {
	"Weapon": {
		"positive": ["attack", "attack"], # attack is twice as likely
		"negative": ["move_speed", "defense"]
	},
	"Armor": {
		"positive": ["defense", "defense", "health"],
		"negative": ["move_speed"]
	},
	"Engine": {
		"positive": ["move_speed", "move_speed"],
		"negative": ["defense", "health"]
	},
    "Scanner": {
        "positive": ["attack", "defense"],
        "negative": ["health"]
    },
    "Cargo": {
        "positive": ["health", "defense"],
        "negative": ["move_speed"]
    }
}

func generate_component() -> GeneratedComponent:
	var component = GeneratedComponent.new()
	var component_type = COMPONENT_TYPES.pick_random()

	# Determine number of positive and negative effects
	var num_positive = randi_range(1, 3)
	var num_negative = randi_range(0, 2)

	var chosen_stats = []

	# Add positive modifiers
	for i in range(num_positive):
		var stat = _get_random_stat(component_type, "positive", chosen_stats)
		if stat:
			component.modifiers[stat] = randi_range(1, 5)
			chosen_stats.append(stat)

	# Add negative modifiers
	for i in range(num_negative):
		var stat = _get_random_stat(component_type, "negative", chosen_stats)
		if stat:
			component.modifiers[stat] = randi_range(-5, -1)
			chosen_stats.append(stat)

	_generate_name_and_description(component, component_type)

	return component

func _get_random_stat(component_type: String, category: String, exclude: Array) -> String:
	var possible_stats = STAT_NAMES.keys()
	var weighted_stats = WEIGHTED_STATS[component_type][category]
	var selection_pool = possible_stats + weighted_stats

	var stat = ""
	while true:
		if selection_pool.is_empty():
			break
		stat = selection_pool.pick_random()
		if not stat in exclude:
			return stat
		else:
			selection_pool.erase(stat)
	return ""

func _generate_name_and_description(component: GeneratedComponent, component_type: String):
	var highest_positive = 0
	var highest_positive_stat = ""
	var highest_negative = 0
	var highest_negative_stat = ""

	var description_text = "Effects:\\n"

	for stat in component.modifiers:
		var value = component.modifiers[stat]
		description_text += "- %s: %+d\\n" % [STAT_NAMES[stat], value]
		if value > 0 and value > highest_positive:
			highest_positive = value
			highest_positive_stat = stat
		elif value < 0 and abs(value) > highest_negative:
			highest_negative = abs(value)
			highest_negative_stat = stat

	component.description = description_text

	var name = component_type
	if highest_positive_stat:
		name += " of " + STAT_NAMES[highest_positive_stat]

	if highest_negative > highest_positive:
		name = "Janky " + name

	component.component_name = name
