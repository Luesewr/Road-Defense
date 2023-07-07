extends GridContainer

@export var selectedNode: TextureButton = null

@export var textures: Dictionary = {
	-1: preload("res://Textures/missing_texture.png"),
	0: preload("res://Textures/grass.png"),
	1: preload("res://Textures/basic_path.png"),
	2: preload("res://Textures/conveyor_path.png"),
}

signal inside_control
signal outside_control

var is_inside = false

func _process(delta):
	var pos = get_global_mouse_position()
	var inside = Rect2(self.position, self.size).has_point(pos)
	if !is_inside and inside:
		is_inside = true
		inside_control.emit()
	elif is_inside and !inside:
		is_inside = false
		outside_control.emit()

func setSelected(node):
	if selectedNode != null:
		selectedNode.dehighlight()
	if selectedNode == node:
		selectedNode = null
	else:
		selectedNode = node
	if selectedNode != null:
		selectedNode.highlight()
