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

# Movement variables
var target_position: Vector2 = Vector2.ZERO

func _ready():
	# Set the initial target position to the current position to prevent moving at the start
	target_position = global_position

func _input(event):
	# Check for a left mouse click to set a new target destination
	if event.is_action_pressed("ui_accept") and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		target_position = get_global_mouse_position()

func _physics_process(delta):
	# Calculate the direction and distance to the target
	var direction = global_position.direction_to(target_position)
	var distance = global_position.distance_to(target_position)

	# Only move if the distance is greater than a small threshold to prevent jittering
	if distance > 5.0:
		# Update velocity based on direction and speed
		velocity = direction * _get_total_speed()
		move_and_slide()
	else:
		# Stop the vehicle when it reaches the destination
		velocity = Vector2.ZERO

# This function will calculate the final speed based on installed components
func _get_total_speed() -> float:
	var total_speed = character_sheet.move_speed if character_sheet else 100.0
	if drive_system and drive_system.has("map_speed_modifier"):
		total_speed += drive_system.map_speed_modifier
	# Add logic for other components that might affect speed
	return total_speed
