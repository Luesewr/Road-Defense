extends Node

@export var TEXTURES: Dictionary = {
	-1: [preload("res://Textures/missing_texture.png")],
	0: [preload("res://Textures/no_texture.png")],
	1: [preload("res://Textures/basic_path.png")],
	2: [preload("res://Textures/corner_path.png")],
	3: [preload("res://Textures/conveyor_path.png"), preload("res://Textures/conveyor_path_2.png"), preload("res://Textures/conveyor_path_3.png"), preload("res://Textures/conveyor_path_4.png")],
}

@export var LOGO_TEXTURES: Dictionary = {
	-1: preload("res://Textures/missing_texture.png"),
	0: preload("res://Textures/no_texture.png"),
	1: preload("res://Textures/basic_path_grass.png"),
	2: preload("res://Textures/corner_path_grass.png"),
	3: preload("res://Textures/conveyor_path_grass.png"),
}

@export var selected_node: TextureButton = null
@export var selected_direction: int = 0
@export var selected_cell: TextureRect = null

var shift_active: bool = false

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

func get_selected_tile_type():
	# Return the tile type of the selected node if one exists or return -1
	var selected = self.selected_node
	
	if selected == null:
		return -1

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
		if cell != null and cell.tile_type > 0:
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
		selected_cell.tile_type = 0
		selected_cell.direction = 0
		selected_cell.set_tile_texture(TEXTURES[0])
	
	var info_box = $CanvasLayer/InfoBox
	info_box.visible = false
