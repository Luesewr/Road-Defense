extends TextureRect

var goal_cell
var current_time: float = 0.0
var start_position: Vector2 = Vector2(0, 0)
var target_position: Vector2 = Vector2(0, 0)
var move_duration = 0.5


func _process(delta):
	current_time += delta

	# Calculate the interpolation factor (between 0 and 1)
	var interpolation_factor : float = clamp(current_time / move_duration, 0, 1)

	# Use lerp to smoothly move the object
	var new_position : Vector2 = lerp(start_position, target_position, interpolation_factor)
	position = new_position

	# Check if the object has reached its destination
	if interpolation_factor == 1:
		if goal_cell.path_neighbours.size() == 0:
			queue_free()
		else:
			goal_cell = goal_cell.path_neighbours[randi() % goal_cell.path_neighbours.size()]
			start_position = self.position
			target_position = goal_cell.position
			current_time = 0
		# Object has reached its goal, you can perform any necessary actions here

func follow_path(cell):
	goal_cell = cell.path_neighbours[0]
	start_position = self.position
	target_position = goal_cell.position
	self.process_mode = Node.PROCESS_MODE_ALWAYS
