extends Resource
class_name CharacterSheet

@export var name: String = "Actor"
@export var health: int = 10
@export var attack: int = 5
@export var defense: int = 5
@export var move_speed: float = 100.0
@export var can_cross_water: bool = false
@export var pacs: int = 0

# --- Inventory ---
@export var inventory_slots: int = 5
@export var stack_size: int = 100
var inventory: Array = [] # Format: [{ "item": "Ore", "quantity": 75 }]

# --- Inventory Management ---

func add_to_inventory(item: String, quantity: int) -> int:
	var remaining_quantity = quantity

	# First, try to stack with existing items
	for slot in inventory:
		if slot["item"] == item and slot["quantity"] < stack_size:
			var can_add = stack_size - slot["quantity"]
			var to_add = min(remaining_quantity, can_add)
			slot["quantity"] += to_add
			remaining_quantity -= to_add
			if remaining_quantity == 0:
				return 0

	# Next, try to fill empty slots
	while remaining_quantity > 0 and inventory.size() < inventory_slots:
		var to_add = min(remaining_quantity, stack_size)
		inventory.append({"item": item, "quantity": to_add})
		remaining_quantity -= to_add

	return remaining_quantity

func remove_from_inventory(item: String, quantity: int) -> int:
	var remaining_quantity = quantity
	for i in range(inventory.size() - 1, -1, -1):
		var slot = inventory[i]
		if slot["item"] == item:
			var to_remove = min(remaining_quantity, slot["quantity"])
			slot["quantity"] -= to_remove
			remaining_quantity -= to_remove
			if slot["quantity"] == 0:
				inventory.remove_at(i)
			if remaining_quantity == 0:
				return 0

	return remaining_quantity

func get_item_quantity(item: String) -> int:
	var total = 0
	for slot in inventory:
		if slot["item"] == item:
			total += slot["quantity"]
	return total
