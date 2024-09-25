"""
A scene representing a fishing ship. 
Used as an instance in the player scene.
"""


extends Area2D


var speed = 80 # How fast the shoal will move (pixels/sec).
var screen_size # Size of the game window.
var movement_area # Area for the ship to navigate within. Passed from the player scene
var efficiency = 0.3 # Proportion of fish in a shoal ship catches upon encounter
var capture = 0 # Ship's capture in the current time period
var active = true # Set to false upon being sold
var inactive_texture = load("res://art/bateau-de-peche-inactive.png")
@onready var sprite = $Sprite2D
@onready var navigation_agent = $NavigationAgent2D


# Called when the node enters the scene tree for the first time
# Gets screen size and hides the scene until the setup is done
func _ready():
	screen_size = Vector2i(get_viewport().get_visible_rect().size.x * 2 / 3, get_viewport().get_visible_rect().size.y)
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame
# Proceeds towards the goal while staying within the navigation and screen bounds
func _process(delta):
	var dir = to_local(navigation_agent.get_next_path_position()).normalized()
	var velocity = dir * speed
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


# Called when navigation target is reached
# Calls the function to set a new target if active; stops if not
func _on_navigation_agent_2d_target_reached():
	if active:
		change_target()
	else:
		stop()


# Sets the navigation agent target to a generated position
func change_target():
	navigation_agent.target_position = generate_pos()


# Generates a random position within the valid navigation and screen bounds
func generate_pos():
	while true:
		var rndX = randi_range(0, screen_size.x)
		var rndY = randi_range(0, screen_size.y)
		var pos = Vector2(rndX, rndY)
		if movement_area.is_inside(pos):
			return pos


# Called when a shoal enters the fishing area
# Fished the shoal if the ship is active; ignores it otherwise
func _on_fishing_area_area_entered(area):
	if not active:
		return
	capture += area.fish_shoal(efficiency)


# Called from within the Player scene when a new time period starts
func reset_capture():
	capture = 0


# Called from the player scene immediately after initializing a ship
# Sets up the movement area, starting position, and starting capture; sets
# initial target; displays the scene
func start(movement_area, pos):
	self.movement_area = movement_area
	self.position = pos
	self.capture = 0
	change_target()
	show()


# Called from the player scene when the ship is sold
# Deactivates the ship and directs it to the set port
func deactivate(port):
	active = false
	sprite.texture = inactive_texture
	navigation_agent.target_position = port


# Deletes the node from the scene tree
func stop():
	queue_free()
