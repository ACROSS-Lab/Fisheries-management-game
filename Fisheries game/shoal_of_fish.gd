"""
A scene representing a shoal of fish. 
Used as an instance in the main game scene.
"""


extends Area2D


var speed = 40 # How fast the shoal will move (pixels/sec).
var screen_size  # Size of the game window.
var movement_area # Area for the shoal to navigate within. Passed from the main game scene
var stock # Current stock of the shoal
var default_stock = 500.0 # Default starting stock for a generic shoal
var growth_rate = 0.001
var K = 100000 # Carrying capacity
@onready var navigation_agent = $NavigationAgent2D
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D


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
# Calls the function to set a new target
func _on_navigation_agent_2d_target_reached():
	change_target()


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


# Called from the main game scene every frame
# Grows the shoal's stock depending on the total stock passed from the main game scene
func grow(total_stock):
	stock += growth_rate * stock * (1 - total_stock / K)
	resize()


# Called from within a ship scene upon encounter. 
# Reduces the amount of fish in the shoal and passes the subtracted amount to the caller as catch 
func fish_shoal(efficiency):
	var fished = efficiency * stock
	stock -= fished
	resize()
	return fished


# Called from the main game scene with a certain probability
# Halves the shoal -- creation of the second split half is handled in the main game scene
func split():
	stock = stock / 2
	resize()


# Resizes the shoal based on the amount of fish in it
func resize():
	sprite.scale = Vector2(sqrt(stock / K), sqrt(stock / K))
	collision_shape.scale = Vector2(sqrt(stock / K), sqrt(stock / K))


# Called from the main game scene immediately after initializing a shoal
# Sets up the movement area, starting position, and starting stock; sets
# initial target; displays the scene
func start(movement_area, pos=null, stock=default_stock):
	self.movement_area = movement_area
	self.stock = stock
	if pos == null:
		self.position = generate_pos()
	else:
		self.position = pos
	change_target()
	resize()
	show()


# Deletes the node from the scene tree
func stop():
	queue_free()
