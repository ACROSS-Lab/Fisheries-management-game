"""
A node that handles communication with the database from the end screen.
"""


extends Node


var http_request: HTTPRequest
signal leaderboard_received


# Called when the node enters the scene tree for the first time
# Creates an HTTPRequest Object and adds it to the scene tree
func _init():
	http_request = HTTPRequest.new()
	add_child(http_request)


# Gets the leaderboard from the database and returns it as an array of 
# dictionaries with the following structure: {"username": String, "score": float}
func get_leaderboard(objective: String):
	var url = "http://localhost:5000/leaderboard?objective=" + objective
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_GET)
	var response = await http_request.request_completed
	var response_code = response[1]
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(response[3].get_string_from_utf8())
		if error == OK:
			var data_received = json.data
			return data_received
		else:
			print("JSON Parse Error: ", json.get_error_message())
			return []
	else:
		print("Failed to retrieve leaderboard")
		return []
