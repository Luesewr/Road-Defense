extends TextureButton

var tileType: int = -1
var highlighted = false
var pressedColor = Color(1, 1, 1)
var unpressedColor = Color(0.7, 0.7, 0.7)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	set_modulate(unpressedColor)
	tileType = get_meta("tile", -1)
	self.texture_normal = get_parent().get("textures")[tileType]

func _on_pressed():
	get_parent().setSelected(self)

func highlight():
	set_modulate(pressedColor)

func dehighlight():
	set_modulate(unpressedColor)
