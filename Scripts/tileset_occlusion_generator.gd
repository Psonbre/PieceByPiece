@tool
extends EditorScript

#This tool script will generate the alternative tiles 
var tilesets := [preload("res://Assets/TileSets/MainTileSet.tres"), preload("res://Assets/TileSets/DirtTileSet.tres")]

func _run() -> void:
	for tileset in tilesets :
		for index in tileset.get_source_count() :
			var id = tileset.get_source_id(index)
			var source := tileset.get_source(id) as TileSetAtlasSource
			var atlas_size := source.get_atlas_grid_size()
			for x in atlas_size.x :
				for y in atlas_size.y :
					var tile := Vector2(x,y)
					if source.has_tile(tile) : 
						remove_alternative_tiles(source, tile)
						create_alternative_tile(source, tile)

func remove_alternative_tiles(source : TileSetAtlasSource, tile : Vector2) :
	while source.has_alternative_tile(tile, source.get_alternative_tile_id(tile, 1)) :
		source.remove_alternative_tile(tile, source.get_alternative_tile_id(tile, 1))

func create_alternative_tile(source : TileSetAtlasSource, tile : Vector2) :
	source.create_alternative_tile(tile, 1)
	var alternative_data := source.get_tile_data(tile, 1) 
	var source_data := source.get_tile_data(tile, 0) 
	alternative_data.set_occluder(1,source.get_tile_data(tile, 0).get_occluder(0))
	
	for index in source_data.get_collision_polygons_count(0) :
		alternative_data.add_collision_polygon(0)
		alternative_data.set_collision_polygon_points(0, index, source_data.get_collision_polygon_points(0, index))
		alternative_data.set_collision_polygon_one_way(0, index, source_data.is_collision_polygon_one_way(0, index))
		alternative_data.set_collision_polygon_one_way_margin(0, index, source_data.get_collision_polygon_one_way_margin(0, index))
