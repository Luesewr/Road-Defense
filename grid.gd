extends TextureRect

var GRID_SIZE: Vector2 = Vector2(25, 25)
var HOVER_COLOR_ACCEPT: Color = Color(0.0, 0.7, 0.0)
var HOVER_COLOR_REJECT: Color = Color(0.7, 0.0, 0.0)
var HOVER_COLOR_NEUTRAL: Color = Color(0.9, 0.9, 0.9)
var HOVER_COLOR_SELECTED: Color = Color(0.5, 0.5, 0.5)
var HOVER_NONE: Color = Color(1.0, 1.0, 1.0)
var CELL_SCALAR: Vector2 = Vector2(3, 3)
var CELL_SIZE: Vector2 = Vector2(32, 32) * CELL_SCALAR

var LEVEL_NODE: Node
var CELL_SCENE: Resource = preload("res://Cell.tscn")
var CELLS: Array[TextureRect] = []

#var TEXTURES: Dictionary
#var LOGO_TEXTURES: Dictionary
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
	
	# Set the size and offset for the direction indicator
	$DirectionIndicator.size = CELL_SIZE
	$DirectionIndicator.pivot_offset = CELL_SIZE / 2
	
	# Enable input processing
	set_process_input(true)

func create_background():
	# Load the grass texture
	var new_texture: Image = Image.load_from_file("res://Textures/grass.png")
	
	# Update the cell size according to the size of the grass texture
	CELL_SIZE = Vector2(new_texture.get_size()) * CELL_SCALAR
	
	# Resize the texture according to the new size with the scalar applied
	new_texture.resize(CELL_SIZE.x, CELL_SIZE.y, Image.INTERPOLATE_NEAREST)
	
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
	cell.position = Vector2(x, y) * CELL_SIZE
	cell.size = CELL_SIZE
	cell.pivot_offset = CELL_SIZE / 2
	cell.index = CELLS.size()

	# Add the cell to the CELLS list
	CELLS.append(cell)

	# Add the new cell to the tree
	add_child(cell)


func _input(event: InputEvent):
	# If the user is in the UI remove any hovering effects and stop showing the direction indicator
	if self.user_in_ui:
		reset_modulation(self.last_hover_index)
		$DirectionIndicator.visible = false

	# Calculate hovering if the mouse was moved
	elif event is InputEventMouseMotion:
		process_hover()

	# Calculate cell interaction when the left mouse button is pressed
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		interact_cell()


func process_hover():
	# Get the mouse position
	var position: Vector2 = get_global_mouse_position()

	# If the mouse is within the cell grid set hover for its location
	if self.grid_rect.has_point(position) and !user_in_ui:
		# Hover over the index
		var index: int = calc_cell_index_from_position(position)
		set_hover(index)
		# Update the location of the direction indicator
		$DirectionIndicator.position = floor(position / CELL_SIZE) * CELL_SIZE

	# If the user was not in the grid remove any hovering effects and stop showing the direction indicator
	else:
		reset_modulation(self.last_hover_index)
		$DirectionIndicator.visible = false


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
	elif selected_tile_type == -1:
		CELLS[index].modulate = HOVER_COLOR_NEUTRAL

	# If cell already has the selected tile type, set the cell's color to the rejected hovering color
	elif get_tile_type(index) > 0:
		CELLS[index].modulate = HOVER_COLOR_REJECT

	# Otherwise, set the cell's color to the accepting hovering color
	else:
		CELLS[index].modulate = HOVER_COLOR_ACCEPT


	# If a tile is selected display the selected tile type on the hovered cell with the current direction
	if selected_tile_type != -1:
		CELLS[index].set_tile_texture(DATA[selected_tile_type]["texture"])
		CELLS[index].rotation = dir_to_rad(self.current_direction)
		# Make the direction indicator visible
		$DirectionIndicator.visible = true

	# Reset the texture and rotation of the cell if no tile is selected
	else:
		reset_texture(index)
	
	# Update the last hovered cell index
	self.last_hover_index = index


func interact_cell():
	# Calculate which cell is being interacted with
	var position: Vector2 = get_global_mouse_position()
	var index: int = calc_cell_index_from_position(position)

	# Check if the currect position is within the grid rect
	if self.grid_rect.has_point(position) and !user_in_ui:
		var selected_tile_type = get_selected_tile_type()
		# If a tile is selected, try to place the tile

		if selected_tile_type != -1:
			try_place_tile(index, selected_tile_type)
			update_selected_cell(null)

		# If no tile was selected, update the selected cell
		else:
			update_selected_cell(CELLS[index])

func try_place_tile(index: int, tile_type: int):
	# Place a tile if the tile type of the cell is nothing or no texture
	if CELLS[index].tile_type <= 0:
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
	$DirectionIndicator.rotation = dir_to_rad(direction)

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
	CELLS[index].set_tile_texture(DATA[get_tile_type(index)]["texture"])
	CELLS[index].rotation = dir_to_rad(get_tile_direction(index))

func calc_cell_index_from_position(position: Vector2) -> int:
	# Calculate index in the grid from the cursor position
	return floor(position.x / CELL_SIZE.x) + floor(position.y / CELL_SIZE.y) * GRID_SIZE.x

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
