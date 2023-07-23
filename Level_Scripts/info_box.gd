extends PanelContainer

signal inside_control_update(in_ui: bool)

var is_inside: bool = false

func _process(_delta: float):
	# Check the mouse is within the control panel
	var inside: bool = Rect2(self.position, self.size).has_point(get_global_mouse_position())

	# Update the is_inside field if it is out of date
	if self.is_inside != inside:

		self.is_inside = inside
		inside_control_update.emit(inside)
