extends Node2D

var GRID_SIZE = Vector2(25, 25)
var HOVER_COLOR_ACCEPT = Color(0.0, 0.7, 0.0)
var HOVER_COLOR_REJECT = Color(0.7, 0.0, 0.0)
var CELL_SCALAR = Vector2(3, 3)
var CELL_SIZE: Vector2

var cell_scene = preload("res://Cell.tscn")

var cells = []
var lastHoverIndex = 0
var user_in_ui = false

var controlPanel: GridContainer
var textures: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	controlPanel = get_node("../CanvasLayer/ControlPanel")
	textures = controlPanel.get("textures")
	create_grid()
	set_process_input(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_grid():
	var cell_instance = cell_scene.instantiate()
	
	CELL_SIZE = cell_instance.get_texture().get_size()
	
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var cell = cell_instance.duplicate()
			cell.position = Vector2(x, y) * CELL_SIZE
			cell.size = CELL_SIZE
			add_child(cell)
			cells.append(cell)
#			var cell = TextureRect.new()
#			cell.texture = textures[0]
#			cell.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func get_selected_tile_type():
	var selected_tile = controlPanel.get("selectedNode")
	
	if selected_tile == null:
		return -1
	
	return selected_tile.get_meta("tile", -1)

func get_tile_type(index):
	return cells[index].get("tileType")

func _input(event):
	var rect = Rect2(Vector2(0, 0), CELL_SIZE * GRID_SIZE)
	# Check for mouse movement
	if event is InputEventMouseMotion and !user_in_ui:
		# Get the mouse position
		var position = get_global_mouse_position()
		# If the mouse is within the cell grid remove the hover effect of the last hovered cell and add the hover effect to the new hovered cell
		if rect.has_point(position):
			# Calculate the index
			var index = floor(position.x / CELL_SIZE.x) + floor(position.y / CELL_SIZE.y) * GRID_SIZE.x
			
			if lastHoverIndex != index and cells.size() > 0:
				
				cells[lastHoverIndex].modulate = Color(1, 1, 1)
				cells[lastHoverIndex].texture = textures[get_tile_type(lastHoverIndex)]
				
			if index < cells.size():
				
				if get_selected_tile_type() != get_tile_type(index):
					cells[index].modulate = HOVER_COLOR_ACCEPT
				else:
					cells[index].modulate = HOVER_COLOR_REJECT
				
				var selected_tile = get_selected_tile_type()
				
				if selected_tile != -1:
					cells[index].texture = textures[selected_tile]
				else:
					cells[index].texture = textures[get_tile_type(index)]
					
				lastHoverIndex = index
		elif cells.size() > 0:
			
			cells[lastHoverIndex].modulate = Color(1, 1, 1)
			cells[lastHoverIndex].texture = textures[get_tile_type(lastHoverIndex)]
	
	if user_in_ui:
		cells[lastHoverIndex].modulate = Color(1, 1, 1)
		cells[lastHoverIndex].texture = textures[get_tile_type(lastHoverIndex)]

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and !user_in_ui:
		# Get the mouse position
		var position = get_global_mouse_position()
		# If the mouse is within the cell grid remove the hover effect of the last hovered cell and add the hover effect to the new hovered cell
		if rect.has_point(position):
			# Calculate the index
			var index = floor(position.x / CELL_SIZE.x) + floor(position.y / CELL_SIZE.y) * GRID_SIZE.x
			var selected_tile = get_selected_tile_type()
			
			if cells.size() > 0 and selected_tile != -1:
				cells[index].set("tileType", get_selected_tile_type())

func _on_control_panel_inside_control():
	user_in_ui = true


func _on_control_panel_outside_control():
	user_in_ui = false
