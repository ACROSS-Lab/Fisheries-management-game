"""
A scene representing the main menu. 
The main scene of the project.
"""


extends Control


var play_scene = preload("res://username_menu.tscn")


# Called when the "Play the game" button is pressed
# Directs the user to the username choice menu
func _on_play_button_pressed():
	get_tree().change_scene_to_packed(play_scene)


# Called when the "View detailed statistics" button is pressed
# Opens the ststistics page in a new tab
func _on_statistics_button_pressed():
	OS.shell_open("http://localhost:5000/statistics")
