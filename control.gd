extends GridContainer

signal inside_control
signal outside_control

var isInside = false

func _process(delta):
	var pos = get_global_mouse_position()
	var inside = Rect2(self.position, self.size).has_point(pos)
	if !isInside and inside:
		isInside = true
		inside_control.emit()
	elif isInside and !inside:
		isInside = false
		outside_control.emit()
