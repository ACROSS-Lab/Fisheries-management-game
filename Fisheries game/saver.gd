"""
A node that handles communication with the database from the main game scene.
"""


extends Node


var http_request: HTTPRequest


# Called when the node enters the scene tree for the first time
# Creates an HTTPRequest Object and adds it to the scene tree
func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)


# Sends player data to the database and returns the corresponding record ID or 1 in case of failure
func send_player_data(username : String, objective : String, total_capture : float, total_profit : float, capture : String, profit : String, fish_population : String, ships : String):
	var url = "http://localhost:5000/submit-data"
	var json = {
		"username": username,
		"objective": objective,
		"total_capture": total_capture,
		"total_profit": total_profit,
		"capture": capture,
		"profit": profit,
		"fish_population": fish_population,
		"ships": ships
	}
	var json_string = JSON.stringify(json)
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	var response = await http_request.request_completed
	var response_code = response[1]
	if response_code == 200:
		print("Data successfully sent to the server")
		json = JSON.new()
		var error = json.parse(response[3].get_string_from_utf8())
		if error == OK:
			var player_id = json.data["id"]
			return player_id
		else:
			print("JSON Parse Error: ", json.get_error_message())
			return 1
	else:
		print("Failed to send data to the server")
		return 1
