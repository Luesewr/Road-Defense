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

var TEXTURES: Dictionary
var LOGO_TEXTURES: Dictionary

var last_hover_index: int = 0
var user_in_ui: bool = false
var current_direction: int = 0

@export var grid_rect: Rect2 = Rect2(Vector2(0, 0), GRID_SIZE * CELL_SIZE)


func _ready():
	LEVEL_NODE = get_node("/root/Level_1")
	TEXTURES = LEVEL_NODE.TEXTURES
	LOGO_TEXTURES = LEVEL_NODE.LOGO_TEXTURES
	
	create_grid()
	
	$DirectionIndicator.size = CELL_SIZE
	$DirectionIndicator.pivot_offset = CELL_SIZE / 2
	
	set_process_input(true)


func create_grid():
	var cell_instance: TextureRect = CELL_SCENE.instantiate()
	
	self.size = CELL_SIZE * GRID_SIZE
	
	var new_texture: Image = Image.load_from_file("res://Textures/grass.png")
	
	CELL_SIZE = Vector2(new_texture.get_size()) * CELL_SCALAR
	
	new_texture.resize(CELL_SIZE.x, CELL_SIZE.y, Image.INTERPOLATE_NEAREST)
	self.texture = ImageTexture.create_from_image(new_texture)
	
	self.grid_rect = Rect2(Vector2(0, 0), CELL_SIZE * GRID_SIZE)
	
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):

			var cell: TextureRect = CELL_SCENE.instantiate()

			cell.position = Vector2(x, y) * CELL_SIZE
			cell.size = CELL_SIZE
			cell.pivot_offset = CELL_SIZE / 2
			cell.index = CELLS.size()

			add_child(cell)

			CELLS.append(cell)


func _input(event: InputEvent):
	
	if self.user_in_ui:
		reset_modulation(self.last_hover_index)
		$DirectionIndicator.visible = false

	elif event is InputEventMouseMotion:
		process_hover()

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		interact_cell()


func process_hover():
	# Get the mouse position
	var position: Vector2 = get_global_mouse_position()
	# If the mouse is within the cell grid set hover for its location
	if self.grid_rect.has_point(position):
		# Hover over the index
		var index: int = calc_cell_index_from_position(position)
		set_hover(index)
		
		$DirectionIndicator.position = floor(position / CELL_SIZE) * CELL_SIZE

	else:

		reset_modulation(self.last_hover_index)
		$DirectionIndicator.visible = false


func set_hover(index: int):
	if self.last_hover_index != index:
		reset_modulation(self.last_hover_index)

	var selected_tile_type: int = get_selected_tile_type()
	var selected_cell: TextureRect = get_selected_cell()

	if selected_cell != null and selected_cell.index == index:
		CELLS[index].modulate = HOVER_COLOR_SELECTED

	elif selected_tile_type == -1:
		CELLS[index].modulate = HOVER_COLOR_NEUTRAL

	elif selected_tile_type == get_tile_type(index):
		CELLS[index].modulate = HOVER_COLOR_REJECT

	else:
		CELLS[index].modulate = HOVER_COLOR_ACCEPT


	if selected_tile_type != -1:
		CELLS[index].set_tile_texture(TEXTURES[selected_tile_type])
		CELLS[index].rotation = dir_to_rad(self.current_direction)
		
		$DirectionIndicator.visible = true

	else:
		reset_texture(index)
		
	self.last_hover_index = index


func interact_cell():
	# Get the mouse position
	var position: Vector2 = get_global_mouse_position()
	var index: int = calc_cell_index_from_position(position)
	# If the mouse is within the cell grid remove the hover effect of the last hovered cell and add the hover effect to the new hovered cell
	if self.grid_rect.has_point(position):
		var selected_tile_type = get_selected_tile_type()
		
		if selected_tile_type != -1:
			place_tile(index, selected_tile_type)
			update_selected_cell(null)
		else:
			update_selected_cell(CELLS[index])


func place_tile(index: int, tile_type: int):
	set_tile_type(index, tile_type)
	set_tile_direction(index, self.current_direction)


func update_selected_cell(cell: TextureRect):
	var currently_selected: TextureRect = get_selected_cell()
	var old_index: int

	if currently_selected != null:
		old_index = currently_selected.index

	set_selected_cell(cell)

	if currently_selected != null:
		reset_modulation(old_index)


func _on_control_panel_inside_control():
	self.user_in_ui = true

func _on_control_panel_outside_control():
	self.user_in_ui = false


func update_direction(direction: int):
	self.current_direction = direction
	$DirectionIndicator.rotation = dir_to_rad(direction)
	process_hover()

func get_selected_tile_type():
	return LEVEL_NODE.get_selected_tile_type()

func set_selected_index(index: int):
	set_selected_cell(CELLS[index])

func set_selected_cell(cell: TextureRect):
	LEVEL_NODE.set_selected_cell(cell)

func get_selected_cell():
	return LEVEL_NODE.selected_cell

func get_tile_type(index: int):
	return CELLS[index].tile_type

func set_tile_type(index: int, tile_type: int):
	CELLS[index].tile_type = tile_type

func get_tile_direction(index: int):
	return CELLS[index].direction

func set_tile_direction(index: int, direction: int):
	CELLS[index].direction = direction

func reset_modulation(index: int):
	var selected_cell: TextureRect = get_selected_cell()

	if selected_cell != null and selected_cell.index == index:
		CELLS[index].modulate = HOVER_COLOR_SELECTED
	else:
		CELLS[index].modulate = HOVER_NONE

	reset_texture(index)

func reset_texture(index: int):
	CELLS[index].set_tile_texture(TEXTURES[get_tile_type(index)])
	CELLS[index].rotation = dir_to_rad(get_tile_direction(index))

func calc_cell_index_from_position(position: Vector2):
	return floor(position.x / CELL_SIZE.x) + floor(position.y / CELL_SIZE.y) * GRID_SIZE.x

func dir_to_rad(direction: int):
	return direction * PI * 0.5
