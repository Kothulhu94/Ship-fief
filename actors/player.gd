extends CharacterBody2D
class_name Player

@export var character_sheet: CharacterSheet

# Vehicle component slots - assign component resources here
@export var drive_system: Resource
@export var armor_plating: Resource
@export var cargo_hold: Resource
@export var scanner: Resource
@export var main_weapon: Resource
@export var auxiliary_system: Resource

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# Set the initial target position to the current position to prevent moving at the start
	navigation_agent.target_position = global_position

func _input(event):
	# Check for a left mouse click to set a new target destination
	if event.is_action_pressed("move"):
		navigation_agent.target_position = get_global_mouse_position()

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_path_position = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	velocity = direction * _get_total_speed()
	move_and_slide()

# This function will calculate the final speed based on installed components
func _get_total_speed() -> float:
	var total_speed = character_sheet.move_speed if character_sheet else 100.0
	if drive_system and drive_system.has("map_speed_modifier"):
		total_speed += drive_system.map_speed_modifier
	# Add logic for other components that might affect speed
	return total_speed
