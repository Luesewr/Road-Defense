extends Camera2D

var rightMouseIsDown = false
var prevCoords = null

var MAX_ZOOM = Vector2(10, 10)
var MIN_ZOOM = Vector2(0.5, 0.5)
var Grid: TextureRect
# Called when the node enters the scene tree for the first time.
func _ready():
	prevCoords = get_viewport().get_mouse_position()
	Grid = get_node("../Grid")
	set_process_input(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var position = get_viewport().get_mouse_position()
	if rightMouseIsDown:
		self.translate((prevCoords - position) / self.zoom)
		clamp_camera()
	prevCoords = position

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
			clamp_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and self.zoom / 1.3 > MIN_ZOOM:
			self.zoom /= 1.3
			self.position -= (0.3 / 1.3 * (get_global_mouse_position() - self.position))
			clamp_camera()

func clamp_camera():
	var gridRect: Rect2 = Grid.get("gridRect")
	var viewportRect = get_viewport_rect()
	viewportRect.size /= self.zoom
	self.position = self.position.clamp(gridRect.position + viewportRect.size / 2, gridRect.end - viewportRect.size / 2)
