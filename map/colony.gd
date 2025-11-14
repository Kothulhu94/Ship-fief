extends Area2D

@export var colony_name: String = "Colony"

# --- Economy ---
@export var production_good: String = "Ore"
@export var consumption_good: String = "Data"
@export var production_rate: float = 1.0 # Units per tick
@export var consumption_rate: float = 0.5 # Units per tick

# --- Inventory & Prices ---
var inventory: Dictionary = {
	"Ore": 100,
	"Data": 50,
	"Parts": 20
}
var prices: Dictionary = {
	"Ore": 10,
	"Data": 20,
	"Parts": 50
}

func _ready():
	# Connect to the global economic ticker
	if get_tree().root.has_node("EconomyTicker"):
		get_tree().root.get_node("EconomyTicker").economy_tick.connect(_on_economy_tick)

# This function is called by the EconomyTicker autoload
func _on_economy_tick():
	# Produce goods
	inventory[production_good] = inventory.get(production_good, 0) + production_rate

	# Consume goods
	inventory[consumption_good] = max(0, inventory.get(consumption_good, 0) - consumption_rate)

	# Update prices based on supply and demand (simple example)
	prices[production_good] = max(5, 20 - inventory[production_good] * 0.1)
	prices[consumption_good] = min(100, 10 + (100 - inventory[consumption_good]) * 0.2)

func get_market_data() -> Dictionary:
	return {
		"inventory": inventory,
		"prices": prices
	}
