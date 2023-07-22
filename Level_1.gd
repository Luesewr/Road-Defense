extends Node

func _on_pressed():
	# Switch the scene to level 1
	get_tree().change_scene_to_file("res://Scenes/Level_1.tscn")
