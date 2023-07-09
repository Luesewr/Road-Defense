extends TextureRect

@export var index: int
@export var tileType: int = 0
@export var direction: int = 0

func set_cell_index(index: int):
	self.index = index

func get_cell_index():
	return self.index

func set_tile_type(tileType: int):
	self.tileType = tileType

func get_tile_type():
	return self.tileType

func set_tile_direction(direction: int):
	self.direction = direction

func get_tile_direction():
	return self.direction
