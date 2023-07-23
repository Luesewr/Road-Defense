extends TextureRect

@export var index: int = -1
@export var tile_type: int = TILE_TYPE.NONE
@export var direction: int = 0
@export var textures: Array

var LEVEL_NODE: Node

var animation_frames_per_second: float = 10.0

func _ready():
	LEVEL_NODE = get_node("/root/Level_1")

func _process(_delta: float):
	# Calculate and set the correct animation frame
	var seconds: float = Time.get_ticks_msec() / 1000.0
	var animation_frame_index: int = floori(self.animation_frames_per_second * seconds) % self.textures.size()
	self.texture = self.textures[animation_frame_index]


func set_tile_texture(new_textures: Array):
	# Cancel texture set if textures argument is invalid
	if new_textures.size() == 0:
		return

	# If the texture is not animated, disable processing, otherwise enable processing
	if new_textures.size() == 1:
		self.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		self.process_mode = Node.PROCESS_MODE_ALWAYS

	# Update the texture and textures field
	self.texture = new_textures[0]
	self.textures = new_textures

func update_tile_texture():
	set_tile_texture(LEVEL_NODE.DATA[self.tile_type]['texture'])
