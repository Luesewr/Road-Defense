extends Node

var TEXTURES: Dictionary = {
	TILE_TYPE.GOAL: [preload("res://Textures/goal.png")],
	TILE_TYPE.SPAWNER: [preload("res://Textures/spawner.png")],
	TILE_TYPE.MISSING: [preload("res://Textures/missing_texture.png")],
	TILE_TYPE.NONE: [preload("res://Textures/no_texture.png")],
	TILE_TYPE.BASIC_PATH: [preload("res://Textures/basic_path.png")],
	TILE_TYPE.CORNER_PATH: [preload("res://Textures/corner_path.png")],
	TILE_TYPE.CONVEYOR_BELT: [preload("res://Textures/conveyor_belt.png"), preload("res://Textures/conveyor_belt_2.png"), preload("res://Textures/conveyor_belt_3.png"), preload("res://Textures/conveyor_belt_4.png")],
}

var LOGO_TEXTURES: Dictionary = {
	TILE_TYPE.GOAL: preload("res://Textures/goal_grass.png"),
	TILE_TYPE.SPAWNER: preload("res://Textures/spawner_grass.png"),
	TILE_TYPE.MISSING: preload("res://Textures/missing_texture.png"),
	TILE_TYPE.NONE: preload("res://Textures/no_texture.png"),
	TILE_TYPE.BASIC_PATH: preload("res://Textures/basic_path_grass.png"),
	TILE_TYPE.CORNER_PATH: preload("res://Textures/corner_path_grass.png"),
	TILE_TYPE.CONVEYOR_BELT: preload("res://Textures/conveyor_belt_grass.png"),
}

var CONNECTION_DIRECTIONS: Dictionary = {
	TILE_TYPE.GOAL: [0, 1, 2, 3],
	TILE_TYPE.SPAWNER: [1],
	TILE_TYPE.MISSING: [],
	TILE_TYPE.NONE: [],
	TILE_TYPE.BASIC_PATH: [0, 2],
	TILE_TYPE.CORNER_PATH: [1, 2],
	TILE_TYPE.CONVEYOR_BELT: [0, 2],
}

@export var PLACEABLE_TILES: Array = [
	TILE_TYPE.BASIC_PATH,
	TILE_TYPE.CORNER_PATH,
	TILE_TYPE.CONVEYOR_BELT,
]

@export var DATA: Dictionary

@export var selected_node: TextureButton = null
@export var selected_direction: int = 0
@export var selected_cell: TextureRect = null

var shift_active: bool = false

func _init():
	DATA = {}
	
	for key in TEXTURES.keys():
		DATA[key] = {
			'texture': TEXTURES[key],
			'logo': LOGO_TEXTURES[key],
			'connections': CONNECTION_DIRECTIONS[key],
		}

func _ready():
	# Enable input processing
	set_process_input(true)

func _input(event: InputEvent):
	# Check if the event is a key press
	if event is InputEventKey:
		# Update shift_activate if SHIFT was pressed
		if event.keycode == KEY_SHIFT:
			self.shift_active = event.is_pressed()
		
		# Check if the R key was pressed
		elif event.keycode == KEY_R and event.is_pressed():
			process_rotation_press()

func process_rotation_press():
	# Decrease or increase the selected direction according to the state of the shift key
	if self.shift_active:
		self.selected_direction = (self.selected_direction - 1 + 4) % 4
	else:
		self.selected_direction = (self.selected_direction + 1) % 4

	# Update the selected direction and recalculate the hovering
	$Grid.update_direction(self.selected_direction)
	$Grid.process_hover()

func set_selected_node(node: TextureButton):
	# Dehighlight old selected
	if self.selected_node != null:
		self.selected_node.dehighlight()

	# Set and highlight the selected node if a different node was selected, then update the selected cell
	if self.selected_node != node:
		self.selected_node = node
		self.selected_node.highlight()

		$Grid.update_selected_cell(null)

	# Reset the selected node if same node was selected again
	else:
		self.selected_node = null

func get_selected_tile_type() -> int:
	# Return the tile type of the selected node if one exists or return TILE_TYPE.NONE
	var selected = self.selected_node
	
	if selected == null:
		return TILE_TYPE.NONE

	return selected.tile_type

func set_selected_cell(cell: TextureRect):
	# Get the info box nodes
	var info_texture = $CanvasLayer/InfoBox/TexturePanel/MarginContainer/InfoTexture
	var info_box = $CanvasLayer/InfoBox

	# Select a cell if there is no selected cell or a different cell was selected
	if self.selected_cell == null or cell == null or self.selected_cell.index != cell.index:
		# Update the selected cell
		self.selected_cell = cell

		# Update the texture of the info box if a cell was selected that is not nothing or no texture
		if cell != null and cell.tile_type > TILE_TYPE.NONE:
			info_texture.texture = LOGO_TEXTURES[cell.tile_type]
			info_box.visible = true
		# Turn off the info box if the previous conditions were not met
		else:
			info_box.visible = false
	# Deselect the cell and turn off the info box if the conditions were not met
	else:
		self.selected_cell = null
		info_box.visible = false

	# Recalculate the hovering
	$Grid.process_hover()


func sell_cell():
	if selected_cell != null:
		selected_cell.tile_type = TILE_TYPE.NONE
		selected_cell.direction = 0
		selected_cell.update_tile_texture()
	
	var info_box = $CanvasLayer/InfoBox
	info_box.visible = false
