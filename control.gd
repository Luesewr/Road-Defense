extends GridContainer

signal inside_control
signal outside_control

var is_inside: bool = false

func _process(delta: float):

	var pos: Vector2 = get_global_mouse_position()
	var inside: bool = Rect2(self.position, self.size).has_point(pos)

	if !self.is_inside and inside:

		self.is_inside = true
		inside_control.emit()

	elif self.is_inside and !inside:

		self.is_inside = false
		outside_control.emit()
