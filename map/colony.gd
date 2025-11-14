extends Area2D

@export var colony_name: String = "Colony"

# --- Health ---
@export var health: float = 100.0
@export var max_health: float = 100.0
var ruined: bool = false

# --- Economy ---
@export var production_good: String = "Food" # This is set for each colony instance
@export var production_rate: float = 2.0 # Units per tick
@export var surplus_threshold: int = 100

# Consumption rate for each good type
@export var consumption_rates: Dictionary = {
	"Food": 0.5,
	"Alloys": 0.5,
	"Textiles": 0.5,
	"Medicine": 0.5,
	"Fuel": 0.5,
	"Data": 0.5
}

# --- Inventory & Prices ---
var inventory: Dictionary = {}
var prices: Dictionary = {}

# --- Packer ---
var packer_scene = preload("res://actors/packer.tscn")
var has_packer: bool = false

func _ready():
	add_to_group("colonies")
	# Initialize inventory and prices for all goods
	for good_type in Goods.TYPES:
		inventory[good_type] = 50 # Start with a base stockpile
		prices[good_type] = 15 # Base price

	# The colony starts with more of the good it produces
	if inventory.has(production_good):
		inventory[production_good] = 150

	# Connect to the global economic ticker
	EconomyTicker.economy_tick.connect(_on_economy_tick)

func spawn_packer(surplus_quantity: int):
	has_packer = true
	var packer = packer_scene.instantiate()
	get_tree().root.add_child(packer)
	packer.set_home_colony(self)
	packer.character_sheet.name = colony_name + " Packer"

	# Give the packer the surplus goods
	inventory[production_good] -= surplus_quantity
	packer.character_sheet.add_to_inventory(production_good, surplus_quantity)

	packer.start_trading_route()

func _on_economy_tick():
	if ruined:
		return # Stop all economic activity if ruined

	# --- Produce Goods ---
	inventory[production_good] += production_rate

	# --- Consume Goods & Update Health ---
	var is_starving = false
	for good_type in Goods.TYPES:
		# A colony does not consume the good it produces
		if good_type == production_good:
			continue

		var rate = consumption_rates.get(good_type, 0.5)
		if inventory[good_type] > 0:
			inventory[good_type] = max(0, inventory[good_type] - rate)
		else:
			# If the colony needs a good and doesn't have it, it's starving
			is_starving = true

	if is_starving:
		health -= 1.0 # Decrease health by 1 each tick it's missing something
		if health <= 0:
			_become_ruined()

	# --- Update Prices (dynamic based on supply) ---
	for good_type in Goods.TYPES:
		var supply = inventory.get(good_type, 0)
		# Price is high when supply is low, and low when supply is high
		prices[good_type] = max(5, 50 - supply * 0.2)

	# --- Packer Spawning ---
	if not has_packer and inventory[production_good] >= surplus_threshold:
		var surplus_to_sell = inventory[production_good] - (surplus_threshold / 2)
		spawn_packer(surplus_to_sell)


func _become_ruined():
	ruined = true
	colony_name += " (Ruined)"
	# In a real game, you might change the appearance, disable interaction, etc.
	print(colony_name + " has fallen into ruin!")
	# We don't need to queue_free the packer, as it will de-spawn itself.

func get_market_data() -> Dictionary:
	return {
		"inventory": inventory,
		"prices": prices,
		"health": health,
		"ruined": ruined
	}
