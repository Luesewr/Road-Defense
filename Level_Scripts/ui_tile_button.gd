extends TextureButton

@export var tile_type: int = 0

var PRESSED_COLOR: Color = Color(1, 1, 1)
var UNPRESSED_COLOR: Color = Color(0.7, 0.7, 0.7)

var LEVEL_NODE: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	set_modulate(UNPRESSED_COLOR)
	LEVEL_NODE = get_node("/root/Level_1")
	self.texture_normal = LEVEL_NODE.DATA[tile_type]["logo"]


func highlight():
	self.modulate = PRESSED_COLOR

func dehighlight():
	self.modulate = UNPRESSED_COLOR


func _on_pressed():
	LEVEL_NODE.set_selected_node(self)
