extends Camera2D

var right_mouse_is_down: bool = false
var prev_coords: Vector2

var MAX_ZOOM: Vector2 = Vector2(10, 10)
var MIN_ZOOM: Vector2 = Vector2(0.5, 0.5)
var ZOOM_FACTOR: float = 0.3
var ZOOM_LOCK: Mutex = Mutex.new()
var GRID: TextureRect

func _ready():
	# Initialise variables and turn on input processing
	self.prev_coords = get_viewport().get_mouse_position()
	GRID = get_node("/root/Level_1/Grid")
	set_process_input(true)


func _process(_delta: float):
	# Get the current mouse position
	var pos: Vector2 = get_viewport().get_mouse_position()

	# If the right mouse button is down, update the camera to the right offset and clamp the camera
	if self.right_mouse_is_down:
		self.translate((self.prev_coords - pos) / self.zoom)
		clamp_camera()

	# Update the previous mouse coordinates
	self.prev_coords = pos

func _input(event: InputEvent):
	# Get the zoom lock to avoid zooming in or out too far
	if event is InputEventMouseButton and ZOOM_LOCK.try_lock():
		# Check which button was pressed and if the maximum or minimum zoom limit has been reached
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# Update the right_mouse_is_down variable accordingly
			self.right_mouse_is_down = event.pressed

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and self.zoom * (1.0 + ZOOM_FACTOR) < MAX_ZOOM:
			# Zoom in the camera and clamp it
			self.zoom *= (1.0 + ZOOM_FACTOR)
			self.position += (ZOOM_FACTOR * (get_global_mouse_position() - self.position))
			clamp_camera()

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and self.zoom / (1.0 + ZOOM_FACTOR) > MIN_ZOOM:
			# Zoom out the camera and clamp it
			self.zoom /= (1.0 + ZOOM_FACTOR)
			self.position -= (ZOOM_FACTOR / (1.0 + ZOOM_FACTOR) * (get_global_mouse_position() - self.position))
			clamp_camera()

		# Release the zoom lock
		ZOOM_LOCK.unlock()

func clamp_camera():
	# Get the size of the cell grid and the viewport
	var grid_rect: Rect2 = GRID.grid_rect
	var viewport_rect: Rect2 = get_viewport_rect()

	# Scale the viewport rect size accounting for the zoom factor
	viewport_rect.size /= self.zoom
	# Update the position of the camera such that the camera viewport is within the bounds of the grid rect
	self.position = self.position.clamp(grid_rect.position + viewport_rect.size / 2, grid_rect.end - viewport_rect.size / 2)
