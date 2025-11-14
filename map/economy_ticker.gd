extends Node

# This signal is emitted every time the economy should update.
signal economy_tick

@onready var timer: Timer = $Timer

func _ready():
	# Connect the timer's timeout signal to our tick function
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# Emit the signal for all colonies to hear
	emit_signal("economy_tick")
