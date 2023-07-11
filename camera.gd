extends Camera2D

var right_mouse_is_down: bool = false
var prev_coords: Vector2

var MAX_ZOOM: Vector2 = Vector2(10, 10)
var MIN_ZOOM: Vector2 = Vector2(0.5, 0.5)
var GRID: TextureRect

func _ready():
	self.prev_coords = get_viewport().get_mouse_position()
	GRID = get_node("/root/Level_1/Grid")
	set_process_input(true)


func _process(delta: float):
	var position: Vector2 = get_viewport().get_mouse_position()

	if self.right_mouse_is_down:
		self.translate((self.prev_coords - position) / self.zoom)
		clamp_camera()

	self.prev_coords = position

func _input(event: InputEvent):
	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT:

			if event.pressed:
				self.right_mouse_is_down = true
			else:
				self.right_mouse_is_down = false

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
	var viewport_rect: Rect2 = get_viewport_rect()
	viewport_rect.size /= self.zoom
	self.position = self.position.clamp(grid_rect.position + viewport_rect.size / 2, grid_rect.end - viewport_rect.size / 2)
