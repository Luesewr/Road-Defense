extends TextureButton

@export var tileType: int = 0

var highlighted = false
var PRESSED_COLOR = Color(1, 1, 1)
var UNPRESSED_COLOR = Color(0.7, 0.7, 0.7)

var LEVEL_NODE: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	set_modulate(UNPRESSED_COLOR)
	LEVEL_NODE = get_node("/root/Level_1")
	self.texture_normal = LEVEL_NODE.logo_textures[tileType]

func _on_pressed():
	LEVEL_NODE.set_selected_node(self)

func highlight():
	set_modulate(PRESSED_COLOR)

func dehighlight():
	set_modulate(UNPRESSED_COLOR)
