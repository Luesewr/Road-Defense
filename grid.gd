extends Node2D

var GRID_SIZE = Vector2(25, 25)
var HOVER_COLOR_ACCEPT = Color(0.0, 0.7, 0.0)
var HOVER_COLOR_REJECT = Color(0.7, 0.0, 0.0)
var HOVER_NONE = Color(1.0, 1.0, 1.0)
var CELL_SCALAR = Vector2(3, 3)
var CELL_SIZE: Vector2 = Vector2(32, 32) * CELL_SCALAR

var cellScene = preload("res://Cell.tscn")

var cells: Array[TextureRect] = []
var lastHoverIndex = 0
var userInUI = false
var currentDirection: int = 0

var rootNode: Node
var directionIndicator: TextureRect
var textures: Dictionary
@export var gridRect: Rect2 = Rect2(Vector2(0, 0), GRID_SIZE * CELL_SIZE)

func _ready():
	rootNode = self.get_owner()
	textures = rootNode.get("textures")
	
	directionIndicator = get_node("DirectionIndicator")
	
	create_grid()
	
	directionIndicator.size = CELL_SIZE
	directionIndicator.pivot_offset = directionIndicator.size / 2
	
	set_process_input(true)

func create_grid():
	var cell_instance = cellScene.instantiate()
	
	CELL_SIZE = cell_instance.get_texture().get_size() * CELL_SCALAR
	gridRect = Rect2(Vector2(0, 0), CELL_SIZE * GRID_SIZE)
	
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var cell = cell_instance.duplicate()
			cell.position = Vector2(x, y) * CELL_SIZE
			cell.size = CELL_SIZE
			cell.pivot_offset = CELL_SIZE / 2
			add_child(cell)
			cells.append(cell)

func _input(event):
	# Check for mouse movement
	if event is InputEventMouseMotion and !userInUI:
		process_hover()
	
	if userInUI:
		reset_modulation(lastHoverIndex)
		directionIndicator.visible = false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and !userInUI:
		place_cell()

func process_hover():
	# Get the mouse position
	var position = get_global_mouse_position()
	# If the mouse is within the cell grid set hover for its location
	if gridRect.has_point(position):
		# Hover over the index
		var index = calc_cell_index_from_position(position)
		set_hover(index)
		
		directionIndicator.visible = true
		directionIndicator.position = floor(position / CELL_SIZE) * CELL_SIZE

	else:
		reset_modulation(lastHoverIndex)
		directionIndicator.visible = false

func set_hover(index: int):
	if lastHoverIndex != index:
		reset_modulation(lastHoverIndex)

	if get_selected_tile_type() == get_tile_type(index):
		cells[index].modulate = HOVER_COLOR_REJECT
	else:
		cells[index].modulate = HOVER_COLOR_ACCEPT
	
	var selected_tile_type = get_selected_tile_type()
	
	if selected_tile_type != -1:
		cells[index].texture = textures[selected_tile_type]
		cells[index].rotation = dir_to_rad(currentDirection)
	else:
		reset_modulation(index)
		
	lastHoverIndex = index

func place_cell():
	# Get the mouse position
	var position = get_global_mouse_position()
	# If the mouse is within the cell grid remove the hover effect of the last hovered cell and add the hover effect to the new hovered cell
	if gridRect.has_point(position):
		# Calculate the index
		var index = calc_cell_index_from_position(position)
		var selected_tile_type = get_selected_tile_type()
		
		if selected_tile_type != -1:
			set_tile_type(index, selected_tile_type)
			set_tile_direction(index, currentDirection)

func _on_control_panel_inside_control():
	userInUI = true

func _on_control_panel_outside_control():
	userInUI = false

func _on_indicator_direction_changed(direction):
	currentDirection = direction
	directionIndicator.rotation = dir_to_rad(direction)
	process_hover()

func get_selected_tile_type():
	return rootNode.get_selected_tile_type()

func get_tile_type(index: int):
	return cells[index].get_tile_type()

func set_tile_type(index: int, tileType: int):
	cells[index].set_tile_type(tileType)

func get_tile_direction(index: int):
	return cells[index].get_tile_direction()

func set_tile_direction(index: int, direction: int):
	cells[index].set_tile_direction(direction)

func reset_modulation(index: int):
	cells[index].modulate = HOVER_NONE
	cells[index].texture = textures[get_tile_type(index)]
	cells[index].rotation = dir_to_rad(get_tile_direction(index))

func calc_cell_index_from_position(position: Vector2):
	return floor(position.x / CELL_SIZE.x) + floor(position.y / CELL_SIZE.y) * GRID_SIZE.x

func dir_to_rad(direction):
	return direction * PI * 0.5
