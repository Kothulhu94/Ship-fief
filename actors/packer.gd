extends CharacterBody2D

@export var character_sheet: CharacterSheet
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var home_colony
var target_colony

var current_state = "IDLE" # States: IDLE, TRADING, RETURNING

func _ready():
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	navigation_agent.set_collision_mask(1) # Assuming the player is on collision layer 1
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
	current_state = "TRADING"
	# For now, just move to a random colony. In a real game, this would be more intelligent.
	var colonies = get_tree().get_nodes_in_group("colonies")
	colonies.erase(home_colony)
	if colonies.size() > 0:
		target_colony = colonies.pick_random()
		navigation_agent.target_position = target_colony.global_position

func _on_target_reached():
	if current_state == "TRADING":
		# Arrived at the target colony, perform the trade
		# In a real game, you'd have logic here to buy/sell goods.
		# For this prototype, we'll just simulate it.
		print(character_sheet.name + " has reached " + target_colony.colony_name)

		# Now, return home
		current_state = "RETURNING"
		navigation_agent.target_position = home_colony.global_position
	elif current_state == "RETURNING":
		# Arrived back at home colony
		print(character_sheet.name + " has returned to " + home_colony.colony_name)
		current_state = "IDLE"
		# Wait a bit before starting a new trade route
		await get_tree().create_timer(5.0).timeout
		start_trading_route()
