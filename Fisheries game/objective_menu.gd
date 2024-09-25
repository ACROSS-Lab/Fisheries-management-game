"""
A scene representing the objective choice menu.
"""


extends Control


var next_scene = preload("res://main.tscn")


# Called when the "Maximize capture" button is pressed
# Sets the objective as "Capture" and starts the game
func _on_capture_button_pressed():
	PlayerData.Objective = "Capture"
	get_tree().change_scene_to_packed(next_scene)


# Called when the "Maximize profit" button is pressed
# Sets the objective as "Profit" and starts the game
func _on_profit_button_pressed():
	PlayerData.Objective = "Profit"
	get_tree().change_scene_to_packed(next_scene)
