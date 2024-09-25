"""
A scene representing the player. 
Used as an instance in the main game scene.
"""


extends Node2D


var ships = [] # Ship scenes owned by the player
var fish_unit_price = 1 # Price of 1.0 unit of fish caught
var ship_maintenance_cost = 100 # Cost of maintaining a ship for 1 day
var ship_buy_cost = 1000 # Cost of buying 1 ship
var ship_sell_cost = 600 # Money earned on selling 1 ship
var starting_ships = 5
var capture = [0] # Time series of daily capture
var profit = [0] # Time series of daily profit
var n_of_ships = [starting_ships] # Time series of number of player's ships
var total_capture = 0 # Total capture since start of the game
var total_profit = 0 # Total profit since start of the game
var ship_trade_finances = 0 # Money lost/earned from buying/selling ships in the current day
var movement_area # Area for the player's ships to navigate within. Passed from the main game scene
var ports # Ports to buy/sell ships in. Passed from the main game scene
@onready var ship_layer = $ShipLayer
var ship_scene = load("res://ship.tscn")


# Called from the main game scene immediately after initializing a player
# Sets up the movement area and ports; adds starting ships
func start(movement_area, ports):
	self.movement_area = movement_area
	self.ports = ports
	for i in range(starting_ships):
		add_ship()


# Called from the main game scene upon the arrival of a new day
# Records and resets daily statistics 
func start_new_day():
	var daily_capture = 0
	for ship in ships:
		daily_capture += ship.capture
		ship.reset_capture()
	capture.append(daily_capture)
	total_capture += daily_capture
	
	var daily_profit = fish_unit_price * daily_capture
	daily_profit += ship_trade_finances
	daily_profit -= ship_maintenance_cost * len(ships)
	profit.append(daily_profit)
	total_profit += daily_profit
	
	n_of_ships.append(len(ships))
	
	ship_trade_finances = 0
	
	return [daily_capture, daily_profit]


# Instantiates, sets up, and launches a ship scene
func add_ship():
	var new_ship = ship_scene.instantiate()
	ship_layer.add_child(new_ship)
	ships.append(new_ship)
	var new_ship_position = ports[randi_range(0, len(ports) - 1)]
	new_ship.start(movement_area, new_ship_position)
	return new_ship


# Removes a ship from the player's fleet
func remove_ship():
	var ship = ships.pop_back()
	ship.deactivate(ports[randi_range(0, len(ports) - 1)])


# Adds a ship and subtracts the corresponding price from daily finances
func buy_ship():
	add_ship()
	ship_trade_finances -= ship_buy_cost

# Removes a ship and adds the corresponding price to daily finances
func sell_ship():
	if len(ships) == 0:
		return
	remove_ship()
	ship_trade_finances += ship_sell_cost


# Gets rid of all ships
func stop():
	for ship in ships:
		ship.stop()
	ships = []
