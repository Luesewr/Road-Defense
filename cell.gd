extends TextureRect

@export var index: int
@export var tile_type: int = 0
@export var direction: int = 0
@export var textures: Array

var animation_frames_per_second: float = 10.0

func _process(delta):
	var seconds = Time.get_ticks_msec() / 1000.0
	var animation_frame_index = floori(animation_frames_per_second * seconds) % textures.size()
	self.texture = textures[animation_frame_index]

func set_cell_index(index: int):
	self.index = index

func get_cell_index():
	return self.index

func set_tile_type(tile_type: int):
	self.tile_type = tile_type

func get_tile_type():
	return self.tile_type

func set_tile_direction(direction: int):
	self.direction = direction

func get_tile_direction():
	return self.direction

func set_tile_texture(textures: Array):
	if texture == null or textures.size() == 0:
		return

	if textures.size() == 1:
		self.process_mode = Node.PROCESS_MODE_DISABLED
		self.texture = textures[0]
	else:
		self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	self.textures = textures
