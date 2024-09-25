"""
A node handling the naviagation area geometry
"""


extends NavigationRegion2D


var vertices # Vertices of the navigation polygon


# Called when the node enters the scene tree for the first time
# Gets the array of vertices and adjusts it to the position of the polygon
func _ready():
	vertices = navigation_polygon.get_outline(0)
	vertices.append(vertices[0])
	for i in range(len(vertices)):
		vertices[i] = vertices[i] + position


# Called from scenes navigating within the bounds when attempting to generate a valid position
# Uses the ray casting algorithm to tell whether the point is within a concave polygon
func is_inside(point):
	var intersections = 0
	for i in range(0, len(vertices) - 1):
		# Checks for the special case when the ray goes through a vertice
		if vertices[i + 1].y == point.y and vertices[i + 1].x > point.x:
			#Finds the second end of the other edge through this vertice
			var next
			if i < len(vertices) - 2:
				next = vertices[i + 2]
			else:
				next = vertices[1]
			# Now we check whether the other ends of both edges are on the same side of the ray
			if (next.y - point.y) * (vertices[i].y - point.y) > 0:
				# If they are, we count it as an intersection to negate the guaranteed intersection with the next segment
				intersections += 1
		# If no special case, check for intersections normally
		elif is_intersecting(vertices[i], vertices[i + 1], point, Vector2(10000, point.y)):
			intersections += 1
			
	if intersections % 2 == 0:
		return false
	else:
		return true


# Checks whether two segments intersect. Part of the ray casting algorithm
func is_intersecting(v1e1, v1e2, v2e1, v2e2):
	# Convert v1 to a line
	var a1 = v1e2.y - v1e1.y
	var b1 = v1e1.x - v1e2.x
	var c1 = v1e2.x * v1e1.y - v1e1.x * v1e2.y
	
	# If endpoints of v2 are on the same side of the line, there is definitely no intersection
	var d1 = a1 * v2e1.x + b1 * v2e1.y + c1
	var d2 = a1 * v2e2.x + b1 * v2e2.y + c1
	if d1 * d2 > 0:
		return false
	
	# Same case for the line containing v2
	var a2 = v2e2.y - v2e1.y
	var b2 = v2e1.x - v2e2.x
	var c2 = v2e2.x * v2e1.y - v2e1.x * v2e2.y
	d1 = a2 * v1e1.x + b2 * v1e1.y + c2
	d2 = a2 * v1e2.x + b2 * v1e2.y + c2
	if d1 * d2 > 0:
		return false
	
	# We eliminated the case when lines intersect, but segments don't. Now eliminate the case of colinearity
	if (a1 * b2) - (a2 * b1) == 0:
		return false
	
	# The only case left is the intersection of the two segments
	return true
