extends TextureButton

@export var tileType: int = 0

var highlighted = false
var pressedColor = Color(1, 1, 1)
var unpressedColor = Color(0.7, 0.7, 0.7)

var rootNode: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	set_modulate(unpressedColor)
	rootNode = self.get_owner()
	self.texture_normal = rootNode.get("textures")[tileType][0]

func _on_pressed():
	rootNode.set_selected_node(self)

func highlight():
	set_modulate(pressedColor)

func dehighlight():
	set_modulate(unpressedColor)
