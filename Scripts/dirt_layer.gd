extends TileMapLayer

const DIRT_ACCENTS_1 = preload("res://Assets/Sprites/Miner/dirt_accents_1.png")
const DIRT_ACCENTS_2 = preload("res://Assets/Sprites/Miner/dirt_accents_2.png")
const DIRT_HIGHLIGHT = preload("res://Scenes/PuzzlePieces/dirt_highlight.tscn")

func _ready() -> void:
	for tile in get_used_cells() :
		var highlight := DIRT_HIGHLIGHT.instantiate()
		add_child(highlight)
		highlight.position = (tile * tile_set.tile_size) + Vector2i(16,16)
		if get_cell_atlas_coords(tile).x > 0 :
			highlight.texture = DIRT_ACCENTS_1
		else :
			highlight.texture = DIRT_ACCENTS_2
			
