"""
A scene representing the username choice menu.
"""


extends Control


@onready var input_field = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/LineEdit
var next_scene = preload("res://mode_menu.tscn")


# Called when the "GO" button is pressed
# Directs the user to the mode choice menu
func _on_button_pressed():
	PlayerData.Username = input_field.text
	get_tree().change_scene_to_packed(next_scene)
