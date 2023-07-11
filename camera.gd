extends Camera2D

var right_mouse_is_down = false
var prev_coords = null

var MAX_ZOOM = Vector2(10, 10)
var MIN_ZOOM = Vector2(0.5, 0.5)
var GRID: TextureRect
# Called when the node enters the scene tree for the first time.
func _ready():
	prev_coords = get_viewport().get_mouse_position()
	GRID = get_node("/root/Level_1/Grid")
	set_process_input(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var position = get_viewport().get_mouse_position()
	if right_mouse_is_down:
		self.translate((prev_coords - position) / self.zoom)
		clamp_camera()
	prev_coords = position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				right_mouse_is_down = true
			else:
				right_mouse_is_down = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and self.zoom * 1.3 < MAX_ZOOM:
			self.zoom *= 1.3
			self.position += (0.3 * (get_global_mouse_position() - self.position))
			clamp_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and self.zoom / 1.3 > MIN_ZOOM:
			self.zoom /= 1.3
			self.position -= (0.3 / 1.3 * (get_global_mouse_position() - self.position))
			clamp_camera()

func clamp_camera():
	var grid_rect: Rect2 = GRID.grid_rect
	var viewportRect = get_viewport_rect()
	viewportRect.size /= self.zoom
	self.position = self.position.clamp(grid_rect.position + viewportRect.size / 2, grid_rect.end - viewportRect.size / 2)
