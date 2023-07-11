extends Node

@export var TEXTURES: Dictionary = {
	-1: [preload("res://Textures/missing_texture.png")],
	0: [preload("res://Textures/no_texture.png")],
	1: [preload("res://Textures/basic_path.png")],
	2: [preload("res://Textures/conveyor_path.png"), preload("res://Textures/conveyor_path_2.png"), preload("res://Textures/conveyor_path_3.png"), preload("res://Textures/conveyor_path_4.png")],
}

@export var LOGO_TEXTURES: Dictionary = {
	-1: preload("res://Textures/missing_texture.png"),
	0: preload("res://Textures/no_texture.png"),
	1: preload("res://Textures/basic_path_grass.png"),
	2: preload("res://Textures/conveyor_path_grass.png"),
}

@export var selected_node: TextureButton = null
@export var selected_direction: int = 0
@export var selected_cell: TextureRect = null

var shift_active: bool = false

func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	if event is InputEventKey and event.keycode == KEY_SHIFT:
		if event.is_pressed() and !shift_active:
			self.shift_active = true
		elif !event.is_pressed():
			self.shift_active = false
	if event is InputEventKey and event.keycode == KEY_R and event.is_pressed():
		if self.shift_active:
			self.selected_direction = (self.selected_direction - 1 + 4) % 4
		else:
			self.selected_direction = (self.selected_direction + 1) % 4
		$Grid.update_direction(self.selected_direction)

func set_selected_node(node: TextureButton):
	# Dehighlight old selected
	if self.selected_node != null:
		self.selected_node.dehighlight()
	# Select and highlight new node, select none if same tile was toggled twice in a row
	if self.selected_node != node:
		self.selected_node = node
		self.selected_node.highlight()
		$Grid.update_selected_cell(null)
	else:
		self.selected_node = null

func get_selected_tile_type():
	var selected = self.selected_node
	
	if selected == null:
		return -1

	return selected.tile_type

func set_selected_cell(cell: TextureRect):
	var info_texture = $CanvasLayer/InfoBox/TexturePanel/MarginContainer/InfoTexture
	var info_box = $CanvasLayer/InfoBox

	if self.selected_cell == null or cell == null or self.selected_cell.index != cell.index:
		self.selected_cell = cell

		if cell != null and cell.tile_type > 0:
			info_texture.texture = LOGO_TEXTURES[cell.tile_type]
			info_box.visible = true
		else:
			info_box.visible = false
	else:
		self.selected_cell = null
		info_box.visible = false

	$Grid.process_hover()
