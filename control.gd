extends GridContainer

signal inside_control
signal outside_control

var is_inside = false

func _process(delta):
	var pos = get_global_mouse_position()
	var inside = Rect2(self.position, self.size).has_point(pos)
	if !is_inside and inside:
		is_inside = true
		inside_control.emit()
	elif is_inside and !inside:
		is_inside = false
		outside_control.emit()
