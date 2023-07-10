extends Node

@export var textures: Dictionary = {
	-1: [preload("res://Textures/missing_texture.png")],
	0: [preload("res://Textures/no_texture.png")],
	1: [preload("res://Textures/basic_path.png")],
	2: [preload("res://Textures/conveyor_path.png"), preload("res://Textures/conveyor_path_2.png"), preload("res://Textures/conveyor_path_3.png"), preload("res://Textures/conveyor_path_4.png")],
}

@export var logo_textures: Dictionary = {
	-1: preload("res://Textures/missing_texture.png"),
	0: preload("res://Textures/no_texture.png"),
	1: preload("res://Textures/basic_path_grass.png"),
	2: preload("res://Textures/conveyor_path_grass.png"),
}

@export var selectedNode: TextureButton = null
@export var selectedDirection: int = 0
@export var selectedCell: TextureRect = null

var shiftActive = false

var Grid: TextureRect

func _ready():
	Grid = get_node("Grid")
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_SHIFT:
		if event.is_pressed() and !shiftActive:
			shiftActive = true
		elif !event.is_pressed():
			shiftActive = false
	if event is InputEventKey and event.keycode == KEY_R and event.is_pressed():
		if shiftActive:
			selectedDirection = (selectedDirection - 1 + 4) % 4
		else:
			selectedDirection = (selectedDirection + 1) % 4
		Grid.update_direction(selectedDirection)

func set_selected_node(node):
	# Dehighlight old selected
	if selectedNode != null:
		selectedNode.dehighlight()
	# Select and highlight new node, select none if same tile was toggled twice in a row
	if selectedNode != node:
		selectedNode = node
		selectedNode.highlight()
		Grid.update_selected_cell(null)
	else:
		selectedNode = null

func get_selected():
	return selectedNode
	
func get_selected_tile_type():
	var selected = get_selected()
	
	if selected == null:
		return -1

	return selected.get("tileType")

func set_selected_cell(cell):
	var infoTexture = $CanvasLayer/InfoBox/TexturePanel/MarginContainer/InfoTexture
	var infoBox = $CanvasLayer/InfoBox
	if self.selectedCell == null or cell == null or self.selectedCell.get_cell_index() != cell.get_cell_index():
		self.selectedCell = cell
		if cell != null && cell.get_tile_type() > 0:
			infoTexture.texture = logo_textures[cell.get_tile_type()]
			infoBox.visible = true
		else:
			infoBox.visible = false
	else:
		self.selectedCell = null
		infoBox.visible = false
	Grid.process_hover()

func get_selected_cell():
	return self.selectedCell
