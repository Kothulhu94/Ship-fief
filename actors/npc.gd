extends CharacterBody2D
class_name NPC

# --- Movement ---
@export var speed: float = 100.0
var current_target: Vector2 = Vector2.ZERO
var wander_radius: float = 300.0

func _ready():
	# Set the initial target to a random point within the wander radius
	_set_new_wander_target()

func _physics_process(delta):
	# Move towards the target
	var direction = global_position.direction_to(current_target)
	velocity = direction * speed
	move_and_slide()

	# If the NPC is close to the target, pick a new one
	if global_position.distance_to(current_target) < 10.0:
		_set_new_wander_target()

func _set_new_wander_target():
	# Choose a random point to move to
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	current_target = global_position + random_direction * wander_radius
