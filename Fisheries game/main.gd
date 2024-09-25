"""
The main game class.
Handles all game logics.
Contains a node with its own script attached that handles the navigation area
geometry -- see the SeaArea node and sea_are.gd
Contains a node with its own script attached that handles communication with
the database -- see the Saver node and saver.gd
"""


extends Node


var shoals = [] # Shoal scenes present in the game
var total_stock = 0 # Total fish stock between all shoals
var fish_population = [] # Time series of fish population
var starting_shoals = 100
var days = 60 # Amount of in-game days. Multiplied by the length of day timer, forms total game duration
var current_day = 0
var capture_plot
var profit_plot
@onready var sea_area = $SeaArea
var ports = []
@onready var player = $Player
@onready var HUD = $HUD
@onready var capture_graph = $StatsLayer/MarginContainer/GraphContainer/CaptureGraph
@onready var profit_graph = $StatsLayer/MarginContainer/GraphContainer/ProfitGraph
@onready var end_timer = $EndTimer
@onready var day_timer = $DayTimer
@onready var score_timer = $ScoreTimer
@onready var saver = $Saver
var shoal_scene = load("res://shoal_of_fish.tscn")
var next_scene = preload("res://end_screen.tscn")


# Called when the node enters the scene tree for the first time
# Collects port positions; sets total game duration; sets up static game elements
func _ready():
	for port in get_tree().get_nodes_in_group("ports"):
		ports.append(port.position)
	
	end_timer.wait_time = day_timer.wait_time * days
	
	capture_plot = capture_graph.add_plot_item("Capture per day, KTons", Color.GREEN, 1.0)
	profit_plot = profit_graph.add_plot_item("Profit per day, 1K USD", Color.GREEN, 1.0)
	capture_graph.x_max = days
	profit_graph.x_max = days
	
	HUD.set_button_text(player.ship_buy_cost, player.ship_sell_cost)
	
	start_new_game()


# Sets up and starts the moving elements; starts all times
func start_new_game():
	for i in range(starting_shoals):
		var shoal = add_shoal()
		shoal.start(sea_area)
		total_stock += shoal.stock
	fish_population.append(total_stock)
	
	player.start(sea_area, ports)
	
	end_timer.start()
	day_timer.start()
	score_timer.start()


# Instantiates and returns a new shoal
func add_shoal():
	var new_shoal = shoal_scene.instantiate()
	add_child(new_shoal)
	shoals.append(new_shoal)
	return new_shoal


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Grows fish stock.
func _process(delta):
	grow_fish_stock()


# Individually grows each shoal according to the total fish stock. With a 
# possibility that depends on the total stock, may split shoals
func grow_fish_stock():
	var updated_stock = 0
	for shoal in shoals:
		updated_stock += shoal.stock
	total_stock = updated_stock
	
	for shoal in shoals:
		shoal.grow(total_stock)
		if shoal.stock > 1000 and flip(0.05 * (1 - len(shoals) / 75.0)):
			shoal.split()
			var new_shoal = add_shoal()
			new_shoal.start(sea_area, shoal.position, shoal.stock)
	
	updated_stock = 0
	for shoal in shoals:
		updated_stock += shoal.stock
	total_stock = updated_stock


# Returns true with the probability p and falso otherwise
func flip(p):
	return randf() <= p


# Called on timeout of the day timer (renewable)
# Updates the time series and plots
func _on_day_timer_timeout():
	fish_population.append(total_stock)
	current_day += 1
	var daily_data = player.start_new_day()
	var daily_capture = daily_data[0]
	var daily_profit = daily_data[1]
	capture_plot.add_point(Vector2(current_day, daily_capture / 1000))
	profit_plot.add_point(Vector2(current_day, daily_profit / 1000))


# Called on timeout of the end timer. 
# Stops all moving objects, saves player data, and sends it to the database. 
# Upon success, directs the user to the end screen.
func _on_end_timer_timeout():
	for shoal in shoals:
		shoal.stop()
	shoals = []
	day_timer.stop()
	score_timer.stop()
	player.stop()
	PlayerData.Capture = player.capture
	PlayerData.Profit = player.profit
	PlayerData.FishPopulation = fish_population
	PlayerData.Ships = player.n_of_ships
	PlayerData.ID = await saver.send_player_data(PlayerData.Username, PlayerData.Objective, sum(PlayerData.Capture), sum(PlayerData.Profit), str(PlayerData.Capture), str(PlayerData.Profit), str(PlayerData.FishPopulation), str(PlayerData.Ships))
	get_tree().change_scene_to_packed(next_scene)


# Returns the sum of all numbers in an array
func sum(arr):
	var s = 0
	for x in arr:
		s += x
	return s


#Called on timeout of the score timer (renewable)
# Updates the scores on the screen
func _on_score_timer_timeout():
	HUD.update_score(len(player.ships), total_stock, player.ship_maintenance_cost, player.total_capture, player.total_profit)
