"""
A scene representing the user interface overlay. 
Used as an instance in the main game scene.
"""


extends CanvasLayer


signal buy_ship
signal sell_ship


# Called when the "Buy ship" button is pressed
# Emits the signal for buying a ship which is then caught by the Player node
func _on_buy_ship_button_pressed():
	buy_ship.emit()


# Called when the "Sell ship" button is pressed
# Emits the signal for selling a ship which is then caught by the Player node
func _on_sell_ship_button_pressed():
	sell_ship.emit()


# Sets the buy/sell button text to match the prices set in the main game scene
func set_button_text(ship_buy_cost, ship_sell_cost):
	$ButtonContainer/HBoxContainer/BuyShipButton.text = "Buy ship (-" + str(ship_buy_cost) + "$)"
	$ButtonContainer/HBoxContainer/SellShipButton.text = "Sell ship (+" + str(ship_sell_cost) + "$)"


# Updates the scores displayed on-screen to match the player's progress
func update_score(ships, fish, cost, capture, profit):
	$ScoreContainer/HBoxContainer/ShipsLabel.text = "Your ships: " + str(ships) + " (maintenance cost: " + str(cost) + "$/ship/day)"
	$ScoreContainer/HBoxContainer/FishPopulationLabel.text = "Fish population: " + str(round(fish))
	$ScoreContainer/HBoxContainer/TotalCaptureLabel.text = "Total capture: " + str(round(capture))
	$ScoreContainer/HBoxContainer/TotalProfitLabel.text = "Balance: " + str(round(profit))
