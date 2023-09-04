extends TextureRect

var GRID_SIZE: Vector2i = Vector2i(25, 25)
var HOVER_COLOR_ACCEPT: Color = Color(0.0, 0.7, 0.0)
var HOVER_COLOR_REJECT: Color = Color(0.7, 0.0, 0.0)
var HOVER_COLOR_NEUTRAL: Color = Color(0.9, 0.9, 0.9)
var HOVER_COLOR_SELECTED: Color = Color(0.5, 0.5, 0.5)
var HOVER_NONE: Color = Color(1.0, 1.0, 1.0)
var CELL_SCALAR: Vector2i = Vector2i(3, 3)
var CELL_SIZE: Vector2i = Vector2i(32, 32) * CELL_SCALAR

var LEVEL_NODE: Node
var CELL_SCENE: Resource = preload("res://Scenes/Cell.tscn")
var CELLS: Array[TextureRect] = []

var SPAWNERS: Array[Vector2i] = [Vector2i(0, 0)]
var GOALS: Array[Vector2i] = [Vector2i(5, 5)]

var DATA: Dictionary

var last_hover_index: int = 0
var user_in_ui: bool = false
var current_direction: int = 0

@export var grid_rect: Rect2 = Rect2(Vector2(0, 0), GRID_SIZE * CELL_SIZE)


func _ready():
	# Initialise variables
	LEVEL_NODE = get_node("/root/Level_1")
	DATA = LEVEL_NODE.DATA
	
	# Create the grass background
	create_background()
	
	# Generate a grid of cells
	create_grid()
	
	# Create the spawning places and goals
	create_spawns_and_goals()
	
	# Set the size and offset for the direction indicator
#	$DirectionIndicator.size = CELL_SIZE
#	$DirectionIndicator.pivot_offset = CELL_SIZE / 2
	
	# Enable input processing
	set_process_input(true)


func create_background():
	# Load the grass texture
	var new_texture: Image = load("res://Textures/grass.png").get_image()
	
	# Update the cell size according to the size of the grass texture
	CELL_SIZE = Vector2i(new_texture.get_size()) * CELL_SCALAR
	
	# Resize the texture according to the new size with the scalar applied
	new_texture.resize(int(CELL_SIZE.x), int(CELL_SIZE.y), Image.INTERPOLATE_NEAREST)
	
	# Set the background texture to the resized grass texture
	self.texture = ImageTexture.create_from_image(new_texture)

func create_grid():
	# Update the size of the container according to the new CELL_SIZE
	self.size = CELL_SIZE * GRID_SIZE
	self.grid_rect = Rect2(Vector2(0, 0), CELL_SIZE * GRID_SIZE)
	
	# Create a cell for each coordinate
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			create_cell(x, y)

func create_cell(x: int, y: int):
	# Instantiate a cell
	var cell: TextureRect = CELL_SCENE.instantiate()

	# Set the fields of the cell
	cell.position = Vector2i(x, y) * CELL_SIZE
	cell.size = CELL_SIZE
	cell.pivot_offset = CELL_SIZE / 2
	cell.index = CELLS.size()
	cell.grid_position = Vector2i(x, y)

	# Add the cell to the CELLS list
	CELLS.append(cell)

	# Add the new cell to the tree
	add_child(cell)

func create_spawns_and_goals():
	for spawn in SPAWNERS:
		var index: int = calc_cell_index_from_cell_position(spawn)
		CELLS[index].tile_type = TILE_TYPE.SPAWNER
		CELLS[index].update_tile_texture()
	
	for goal in GOALS:
		var index: int = calc_cell_index_from_cell_position(goal)
		CELLS[index].tile_type = TILE_TYPE.GOAL
		CELLS[index].update_tile_texture()

func _input(event: InputEvent):
	# If the user is in the UI remove any hovering effects and stop showing the direction indicator
	if self.user_in_ui:
		reset_modulation(self.last_hover_index)
#		$DirectionIndicator.visible = false

	# Calculate hovering if the mouse was moved
	elif event is InputEventMouseMotion:
		process_hover()

	# Calculate cell interaction when the left mouse button is pressed
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		interact_cell()


func process_hover():
	# Get the mouse position
	var pos: Vector2 = get_global_mouse_position()

	# If the mouse is within the cell grid set hover for its location
	if self.grid_rect.has_point(pos) and !user_in_ui:
		# Hover over the index
		var index: int = calc_cell_index_from_position(pos)
		set_hover(index)
		# Update the location of the direction indicator
#		$DirectionIndicator.position = floor(pos / CELL_SIZE) * CELL_SIZE

	# If the user was not in the grid remove any hovering effects and stop showing the direction indicator
	else:
		reset_modulation(self.last_hover_index)
#		$DirectionIndicator.visible = false


func set_hover(index: int):
	# Reset the hovering of the previous cell if the user changed which cell they hover over
	if self.last_hover_index != index:
		reset_modulation(self.last_hover_index)

	# Get which cell and tile type are selected
	var selected_tile_type: int = get_selected_tile_type()
	var selected_cell: TextureRect = get_selected_cell()

	# If the hovered cell is the selected cell, set the cell's color to the selected cell color
	if selected_cell != null and selected_cell.index == index:
		CELLS[index].modulate = HOVER_COLOR_SELECTED

	# If there is no tile type selected, set the cell's color to the neutral hovering color
	elif selected_tile_type == TILE_TYPE.NONE:
		CELLS[index].modulate = HOVER_COLOR_NEUTRAL

	# If cell already has the selected tile type, set the cell's color to the rejected hovering color
	elif get_tile_type(index) != TILE_TYPE.NONE:
		CELLS[index].modulate = HOVER_COLOR_REJECT

	# Otherwise, set the cell's color to the accepting hovering color
	else:
		CELLS[index].modulate = HOVER_COLOR_ACCEPT


	# If a tile is selected display the selected tile type on the hovered cell with the current direction
	if selected_tile_type != TILE_TYPE.NONE:
		CELLS[index].set_tile_texture(DATA[selected_tile_type]["texture"])
		CELLS[index].rotation = dir_to_rad(self.current_direction)
		# Make the direction indicator visible
#		$DirectionIndicator.visible = true

	# Reset the texture and rotation of the cell if no tile is selected
	else:
		reset_texture(index)
	
	# Update the last hovered cell index
	self.last_hover_index = index


func interact_cell():
	# Calculate which cell is being interacted with
	var pos: Vector2 = get_global_mouse_position()
	var index: int = calc_cell_index_from_position(pos)

	# Check if the currect position is within the grid rect
	if self.grid_rect.has_point(pos) and !user_in_ui:
		var selected_tile_type: int = get_selected_tile_type()
		# If a tile is selected, try to place the tile

		if selected_tile_type != TILE_TYPE.NONE:
			try_place_tile(index, selected_tile_type)
			update_selected_cell(null)

		# If no tile was selected, update the selected cell
		elif selected_tile_type == TILE_TYPE.NONE and get_tile_type(index) in LEVEL_NODE.PLACEABLE_TILES:
			update_selected_cell(CELLS[index])


func connect_paths():
	var valid: bool = true
	
	for goal in GOALS:
		var goal_index: int = calc_cell_index_from_cell_position(goal)
		var goal_cell: TextureRect = CELLS[goal_index]
		
		var stack: Array[StackElement] = [StackElement.new(goal_cell, null)]
		
		var found_spawner: bool = false
		
		while valid && stack.size() > 0:
			var current_element: StackElement = stack.pop_back()
			var current: TextureRect = current_element.current
			
			var current_visited: VisitedNode = current_element.visited
			
			var new_visited: VisitedNode = VisitedNode.new(current, current_visited)
			
			for spawner in SPAWNERS:
				if spawner == current.grid_position:
					found_spawner = true
					new_visited.add_neighbours()
					break
			
			for direction in DATA[current.tile_type]['connections']:
				var adjusted_direction: int = (direction + current.direction) % 4
				var x: int = current.grid_position.x + ((1 if adjusted_direction % 2 == 1 else 0) * (1 if adjusted_direction < 2 else -1))
				var y: int = current.grid_position.y + ((1 if adjusted_direction % 2 == 0 else 0) * (1 if adjusted_direction > 1 else -1))
				var neighbour_location: Vector2i = Vector2i(x, y)
				
				if x < 0 or x >= GRID_SIZE.x or y < 0 or y >= GRID_SIZE.y:
					valid = false
					break
				
				var neighbour: TextureRect = CELLS[calc_cell_index_from_cell_position(neighbour_location)]
				
				if neighbour.tile_type not in LEVEL_NODE.VALID_TILES:
					valid = false
					break
				
				if current_visited != null and current_visited.contains(neighbour):
					continue
				
				stack.push_back(StackElement.new(neighbour, new_visited))
				
		if !found_spawner:
			valid = false
			
	if valid:
		for spawner in SPAWNERS:
			if CELLS[calc_cell_index_from_cell_position(spawner)].path_neighbours.size() == 0:
				valid = false
				break
	
	print("valid" if valid else "not valid")

class VisitedNode:
	var cell: TextureRect
	var next_node: VisitedNode
	
	func _init(cell: TextureRect, next: VisitedNode):
		self.cell = cell
		self.next_node = next
	
	func contains(element: TextureRect):
		if self.cell == element:
			return true
		
		if self.next_node != null:
			return self.next_node.contains(element)
		else:
			return false
	
	func head():
		return self.cell
	
	func tail():
		if self.next_node == null:
			return self.cell
		
		return self.next_node.tail()
	
	func add_neighbours():
		if self.next_node == null:
			return
		
		if !self.cell.path_neighbours.has(self.next_node):
			self.cell.path_neighbours.push_back(self.next_node)

class StackElement:
	var visited: VisitedNode
	var current: TextureRect
	
	func _init(current: TextureRect, visited: VisitedNode):
		self.current = current
		self.visited = visited

func try_place_tile(index: int, tile_type: int):
	# Place a tile if the tile type of the cell is nothing or no texture
	if CELLS[index].tile_type == TILE_TYPE.NONE:
		place_tile(index, tile_type)

func place_tile(index: int, tile_type: int):
	# Place a tile on the index of type tile_type in the current direction
	set_tile_type(index, tile_type)
	set_tile_direction(index, self.current_direction)

func update_selected_cell(cell: TextureRect):
	# Get the current selected cell
	var currently_selected: TextureRect = get_selected_cell()
	var old_index: int

	# If a cell was selected, update the old_index variable to its index
	if currently_selected != null:
		old_index = currently_selected.index

	# Update the selected cell
	set_selected_cell(cell)

	# Reset the appearance of the previously selected cell if there was one
	if currently_selected != null:
		reset_modulation(old_index)

func update_direction(direction: int):
	# Update the current direction and update the direction of the direction indicator
	self.current_direction = direction
#	$DirectionIndicator.rotation = dir_to_rad(direction)

func reset_modulation(index: int):
	# Get the selected cell
	var selected_cell: TextureRect = get_selected_cell()

	# Keep the cell color as the selected color if the cell that is being reset is the selected node
	if selected_cell != null and selected_cell.index == index:
		CELLS[index].modulate = HOVER_COLOR_SELECTED

	# Otherwise, remove the hover effect
	else:
		CELLS[index].modulate = HOVER_NONE

	# Reset the texture of the cell
	reset_texture(index)

func reset_texture(index: int):
	# Set the texture and rotation of a cell back to its original values
	CELLS[index].update_tile_texture()
	CELLS[index].rotation = dir_to_rad(get_tile_direction(index))

func calc_cell_index_from_position(pos: Vector2) -> int:
	# Calculate index in the grid from the cursor position
#	return floor(pos.x / CELL_SIZE.x) + floor(pos.y / CELL_SIZE.y) * GRID_SIZE.x
	return calc_cell_index_from_cell_position(Vector2i(floor(pos / Vector2(CELL_SIZE))))

func calc_cell_index_from_cell_position(pos: Vector2i) -> int:
	return pos.x + pos.y * int(GRID_SIZE.x)

func dir_to_rad(direction: int) -> float:
	# Calculate the angle in radians from the direction integer
	return direction * PI * 0.5


func get_selected_tile_type() -> int:
	return LEVEL_NODE.get_selected_tile_type()

func set_selected_index(index: int):
	set_selected_cell(CELLS[index])

func set_selected_cell(cell: TextureRect):
	LEVEL_NODE.set_selected_cell(cell)

func get_selected_cell() -> TextureRect:
	return LEVEL_NODE.selected_cell

func get_tile_type(index: int) -> int:
	return CELLS[index].tile_type

func set_tile_type(index: int, tile_type: int):
	CELLS[index].tile_type = tile_type

func get_tile_direction(index: int) -> int:
	return CELLS[index].direction

func set_tile_direction(index: int, direction: int):
	CELLS[index].direction = direction


func _on_inside_control_update(in_ui: bool):
	self.user_in_ui = in_ui

func _on_play():
	connect_paths()
