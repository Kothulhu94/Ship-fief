extends CharacterBody2D
class_name RecruitableCrew

# --- Recruitment Stats ---
@export var character_sheet: CharacterSheet

# This NPC uses the base NPC movement logic
@onready var npc_movement = preload("res://actors/npc.gd").new()

func _ready():
	# Add the movement logic as a child node
	add_child(npc_movement)

func _physics_process(delta):
	# Delegate the movement to the npc_movement node
	npc_movement._physics_process(delta)
	velocity = npc_movement.velocity
	move_and_slide()

# --- Player Interaction ---
# This would be triggered by player input, e.g., a click. For this prototype,
# we'll assume the player can click on them. We'll add a placeholder for that.
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and get_rect().has_point(to_local(event.position)) and event.is_pressed():
		_on_player_interaction()

func _on_player_interaction():
	# For the prototype, we'll just show a dialogue.
	if character_sheet:
		var text = "This crew is looking for a captain. Cost: " + str(character_sheet.pacs) + " pacs."
		get_tree().root.get_node("World/GameUI").show_dialogue("Recruitment Opportunity", text)
