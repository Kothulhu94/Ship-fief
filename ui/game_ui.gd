extends CanvasLayer

# --- UI Node References ---
@onready var marketplace_panel: Panel = %MarketplacePanel
@onready var hangar_panel: Panel = %HangarPanel
@onready var dialogue_panel: Panel = %DialoguePanel
@onready var dialogue_title: Label = %DialogueTitle
@onready var dialogue_text: Label = %DialogueText

func _ready():
	# Hide all UI panels by default
	marketplace_panel.hide()
	hangar_panel.hide()
	dialogue_panel.hide()

	# Connect to the combat_ended signal from the global event bus
	GameEvents.combat_ended.connect(_on_combat_ended)

func _on_combat_ended(combat_log: String):
	show_dialogue("Beast Encounter!", combat_log)


# --- Public Functions to Control UI ---

func show_marketplace(colony_data: Dictionary):
	# In a real game, you would populate the UI with items, prices, etc.
	print("Showing market for: ", colony_data)
	# For the prototype, we just show the panel.
	marketplace_panel.show()
	hangar_panel.hide()
	dialogue_panel.hide()

func show_hangar():
	# In a real game, you would populate this with the player's ship components.
	print("Showing hangar.")
	hangar_panel.show()
	marketplace_panel.hide()
	dialogue_panel.hide()

func show_dialogue(title: String, text: String):
	dialogue_title.text = title
	dialogue_text.text = text
	dialogue_panel.show()
	marketplace_panel.hide()
	hangar_panel.hide()

func hide_all():
	marketplace_panel.hide()
	hangar_panel.hide()
	dialogue_panel.hide()
