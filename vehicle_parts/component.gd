extends Resource
class_name VehicleComponent

# --- Basic Info ---
@export var component_name: String = "Component"
@export var description: String = "A component for the vehicle."

# --- Stat Modifiers ---
# Drive System
@export var map_speed_modifier: float = 0.0

# Armor Plating
@export var armor_modifier: float = 0.0

# Cargo Hold
@export var cargo_capacity_modifier: int = 0

# Scanner
@export var scanner_range_modifier: float = 0.0

# Weapon
@export var weapon_damage_modifier: float = 0.0

# Auxiliary System
@export var energy_cost_modifier: float = 0.0
