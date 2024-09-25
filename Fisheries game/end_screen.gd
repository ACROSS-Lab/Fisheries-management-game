"""
A scene representing the end screen. 
Contains a node with its own script attached that handles communication with
the database -- see the Loader node and loader.gd
"""


extends Control


var objective = PlayerData.Objective
var capture = sum(PlayerData.Capture)
var profit = sum(PlayerData.Profit)
var fish_population = PlayerData.FishPopulation[-1]
var ships = PlayerData.Ships[-1]
@onready var result_label = $MarginContainer/VBoxContainer/Result
@onready var statistics_label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/StatisticsContainer/Statistics
@onready var leaderboard_label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/LeaderboardContainer/Leaderboard
@onready var loader = $Loader
var menu_scene = load("res://main_menu.tscn")
var objective_scene = load("res://objective_menu.tscn")


# Called when the node enters the scene tree for the first time
# Immediately calls all the functions that update data on the screen
func _ready():
	update_result()
	update_statistics()
	update_leaderboard()


# Dislays the player's game objective and final score
func update_result():
	result_label.text = "Your objective: " + objective + "\nYour result: "
	if objective == "Capture":
		result_label.text += str(round(capture))
	elif objective == "Profit":
		result_label.text += str(round(profit))


# Displays the final game statistics
func update_statistics():
	statistics_label.text = "Total capture: " + str(round(capture)) + "\nTotal profit: " + str(round(profit)) + "\nFish population: " + str(round(fish_population)) + "\nShips: " + str(ships)


# Gets data from the database and displays the current top 5 places on the 
# leaderboard for the player's objective
func update_leaderboard():
	var leaderboard_text = ""
	var data = await loader.get_leaderboard(objective)
	for user in data:
		var username = user["username"]
		var score = str(round(user["score"]))
		leaderboard_text += username + ": " + score + "\n"
	leaderboard_label.text = leaderboard_text


# Returns the sum of all numbers in an array
func sum(arr):
	var s = 0
	for x in arr:
		s += x
	return s


# Called when the "Main menu" button is pressed
# Directs the player to the main menu
func _on_menu_button_pressed():
	get_tree().change_scene_to_packed(menu_scene)


# Called when the "Replay" button is pressed
# Directs the player to the objective choice menu, keeps the username
func _on_replay_button_pressed():
	get_tree().change_scene_to_packed(objective_scene)


# Called when the "Detailed statistics" button is pressed
# Opens the detailed statistics page in a new tab; selects the player in the list automatically
func _on_statistics_button_pressed():
	OS.shell_open("http://localhost:5000/statistics?autoSelectId=" + str(PlayerData.ID))
