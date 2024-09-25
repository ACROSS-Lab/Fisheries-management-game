"""
A scene representing the mode choice menu.
"""


extends Control


var next_scene = preload("res://objective_menu.tscn")


# Called when the "Single player" button is pressed
# Directs the user to the objective choice menu
func _on_single_player_button_pressed():
	get_tree().change_scene_to_packed(next_scene)
