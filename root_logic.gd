extends Node

@export var textures: Dictionary = {
	-1: preload("res://Textures/missing_texture.png"),
	0: preload("res://Textures/grass.png"),
	1: preload("res://Textures/basic_path.png"),
	2: preload("res://Textures/conveyor_path.png"),
}

@export var selectedNode: TextureButton = null
@export var selectedDirection: int = 0

var shiftActive = false

signal direction_changed

func _ready():
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
		direction_changed.emit(selectedDirection)
		

func set_selected(node):
	# Dehighlight old selected
	if selectedNode != null:
		selectedNode.dehighlight()
	# Select and highlight new node, select none if same tile was toggled twice in a row
	if selectedNode != node:
		selectedNode = node
		selectedNode.highlight()
	else:
		selectedNode = null

func get_selected():
	return selectedNode
	
func get_selected_tile_type():
	var selected = get_selected()
	
	if selected == null:
		return -1

	return selected.get_meta("tile", -1)
