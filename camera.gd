extends Camera2D

var rightMouseIsDown = false
var prevCoords = null

var MAX_ZOOM = Vector2(10, 10)
var MIN_ZOOM = Vector2(0.2, 0.2)
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	prevCoords = get_viewport().get_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rightMouseIsDown:
		self.translate((prevCoords - get_viewport().get_mouse_position()) / self.zoom)
	prevCoords = get_viewport().get_mouse_position()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				rightMouseIsDown = true
			else:
				rightMouseIsDown = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and self.zoom * 1.3 < MAX_ZOOM:
			self.zoom *= 1.3
			self.position += (0.3 * (get_global_mouse_position() - self.position))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and self.zoom / 1.3 > MIN_ZOOM:
			self.zoom /= 1.3
			self.position -= (0.3 / 1.3 * (get_global_mouse_position() - self.position))
