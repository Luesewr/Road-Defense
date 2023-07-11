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

@export var selected_node: TextureButton = null
@export var selected_direction: int = 0
@export var selected_cell: TextureRect = null

var shift_active = false

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_SHIFT:
		if event.is_pressed() and !shift_active:
			shift_active = true
		elif !event.is_pressed():
			shift_active = false
	if event is InputEventKey and event.keycode == KEY_R and event.is_pressed():
		if shift_active:
			selected_direction = (selected_direction - 1 + 4) % 4
		else:
			selected_direction = (selected_direction + 1) % 4
		$Grid.update_direction(selected_direction)

func set_selected_node(node):
	# Dehighlight old selected
	if selected_node != null:
		selected_node.dehighlight()
	# Select and highlight new node, select none if same tile was toggled twice in a row
	if selected_node != node:
		selected_node = node
		selected_node.highlight()
		$Grid.update_selected_cell(null)
	else:
		selected_node = null

func get_selected():
	return selected_node
	
func get_selected_tile_type():
	var selected = get_selected()
	
	if selected == null:
		return -1

	return selected.get("tileType")

func set_selected_cell(cell):
	var info_texture = $CanvasLayer/InfoBox/TexturePanel/MarginContainer/InfoTexture
	var info_box = $CanvasLayer/InfoBox
	if self.selected_cell == null or cell == null or self.selected_cell.get_cell_index() != cell.get_cell_index():
		self.selected_cell = cell
		if cell != null && cell.get_tile_type() > 0:
			info_texture.texture = logo_textures[cell.get_tile_type()]
			info_box.visible = true
		else:
			info_box.visible = false
	else:
		self.selected_cell = null
		info_box.visible = false
	$Grid.process_hover()

func get_selected_cell():
	return self.selected_cell
