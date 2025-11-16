extends CharacterBody2D
class_name Packer

@export var character_sheet: CharacterSheet
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var home_colony
var target_colony
var colonies_visited = []

var current_state = "SELLING" # States: SELLING, BUYING, RETURNING

func _ready():
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	navigation_agent.set_collision_mask(1)
	navigation_agent.connect("target_reached", Callable(self, "_on_target_reached"))

func set_home_colony(colony):
	home_colony = colony
	global_position = home_colony.global_position

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_path_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	velocity = direction * character_sheet.move_speed
	move_and_slide()

func start_trading_route():
	find_next_colony()

func find_next_colony():
	var closest_colony = null
	var min_distance = INF

	for colony in get_tree().get_nodes_in_group("colonies"):
		if colony == home_colony or colony in colonies_visited or colony.ruined:
			continue

		var distance = global_position.distance_to(colony.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_colony = colony

	if closest_colony:
		target_colony = closest_colony
		navigation_agent.target_position = target_colony.global_position
		colonies_visited.append(target_colony)
	else:
		# No more colonies to visit, return home
		current_state = "RETURNING"
		navigation_agent.target_position = home_colony.global_position

func _on_target_reached():
	if current_state == "SELLING":
		perform_selling()
		if _has_surplus_goods():
			find_next_colony()
		else:
			current_state = "BUYING"
			find_next_colony()
	elif current_state == "BUYING":
		perform_buying()
		if _can_buy_more_goods():
			find_next_colony()
		else:
			current_state = "RETURNING"
			navigation_agent.target_position = home_colony.global_position
	elif current_state == "RETURNING":
		deposit_goods()
		home_colony.has_packer = false
		queue_free()

func perform_selling():
	for slot in character_sheet.inventory:
		if slot["item"] == home_colony.production_good:
			var price = target_colony.prices[slot["item"]]
			var quantity_to_sell = slot["quantity"]
			target_colony.inventory[slot["item"]] += quantity_to_sell
			character_sheet.pacs += price * quantity_to_sell
			character_sheet.remove_from_inventory(slot["item"], quantity_to_sell)

func perform_buying():
	var needed_good = _get_most_needed_good()
	if needed_good:
		var price = target_colony.prices[needed_good]
		if price <= character_sheet.pacs:
			var quantity_to_buy = min(target_colony.inventory[needed_good], floor(character_sheet.pacs / price))
			quantity_to_buy = min(quantity_to_buy, character_sheet.stack_size - character_sheet.get_item_quantity(needed_good))

			if quantity_to_buy > 0:
				target_colony.inventory[needed_good] -= quantity_to_buy
				character_sheet.pacs -= price * quantity_to_buy
				character_sheet.add_to_inventory(needed_good, quantity_to_buy)

func _has_surplus_goods() -> bool:
	return character_sheet.get_item_quantity(home_colony.production_good) > 0

func _can_buy_more_goods() -> bool:
	return character_sheet.inventory.size() < character_sheet.inventory_slots and character_sheet.pacs > 0

func _get_most_needed_good() -> String:
	var least_quantity = INF
	var most_needed_good = ""
	for good in Goods.TYPES:
		if good == home_colony.production_good:
			continue

		var quantity = home_colony.inventory[good]
		if quantity < least_quantity:
			least_quantity = quantity
			most_needed_good = good

	return most_needed_good

func deposit_goods():
	for slot in character_sheet.inventory:
		home_colony.inventory[slot["item"]] += slot["quantity"]
	home_colony.pacs += character_sheet.pacs
