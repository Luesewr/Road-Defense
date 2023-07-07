extends Node

@export var textures: Dictionary = {
	-1: preload("res://Textures/missing_texture.png"),
	0: preload("res://Textures/grass.png"),
	1: preload("res://Textures/basic_path.png"),
	2: preload("res://Textures/conveyor_path.png"),
}

@export var selectedNode: TextureButton = null

func set_selected(node):
	if selectedNode != null:
		selectedNode.dehighlight()
	if selectedNode == node:
		selectedNode = null
	else:
		selectedNode = node
	if selectedNode != null:
		selectedNode.highlight()

func get_selected():
	return selectedNode
	
func get_selected_tile_type():
	var selected = get_selected()
	
	if selected == null:
		return -1

	return selected.get_meta("tile", -1)
