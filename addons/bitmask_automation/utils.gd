extends Node

const MAX_INT = 9223372036854775807

## Iterates the full positive int64 space desperately searching for
## TileSetAtlasSource's to return to you in a nice little Array that
## may be too convenient for your own good.
static func get_atlas_sources(tile_set: TileSet) -> Array[TileSetAtlasSource]:
	var sources: Array[TileSetAtlasSource] = []
	
	var total := tile_set.get_source_count()
	var seen := 0
	var i := 0
	
	while i <= MAX_INT:
		if seen == total:
			break
		if tile_set.has_source(i):
			seen += 1
			var src := tile_set.get_source(i)
			if src is TileSetAtlasSource:
				sources.push_back(src)
		i += 1
		
	return sources

class BitMaskImageCell:
	var coords: Vector2i
	var terrain: Color
	var neighbors: Dictionary[TileSet.CellNeighbor, Color]

	func print2():
		print(coords)
		print(neighbors[TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER].to_html(), neighbors[TileSet.CELL_NEIGHBOR_TOP_SIDE].to_html(), neighbors[TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER].to_html())
		print(neighbors[TileSet.CELL_NEIGHBOR_LEFT_SIDE].to_html(), terrain.to_html(), neighbors[TileSet.CELL_NEIGHBOR_RIGHT_SIDE].to_html())
		print(neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER].to_html(), neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_SIDE].to_html(), neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER].to_html())

class BitMaskImageParseResult:
	var colors: Array[Color]
	var cells: Array[BitMaskImageCell]
	var size: Vector2i

	static func from_image(img: Image, cell_width: int, cell_height: int) -> BitMaskImageParseResult:
		var result = BitMaskImageParseResult.new()
		result.colors = [] as Array[Color]
		result.cells = [] as Array[BitMaskImageCell]

		var img_size := img.get_size()
		result.size = Vector2i(img_size.x / cell_width, img_size.y / cell_height)

		var hex_codes: Array[String] = []
		for y in range(img_size.y / cell_height):
			for x in range(img_size.x / cell_width):
				var cell := BitMaskImageCell.new()
				cell.coords = Vector2(x, y)
				
				var x_offset := x * cell_width
				var y_offset := y * cell_height

				cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER] = img.get_pixel(x_offset + 0, y_offset + 0)
				cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_SIDE] = img.get_pixel(x_offset + floor(cell_width / 2.0), y_offset + 0)
				cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER] = img.get_pixel(x_offset + cell_width - 1, y_offset + 0)

				cell.neighbors[TileSet.CELL_NEIGHBOR_LEFT_SIDE] = img.get_pixel(x_offset + 0, y_offset + floor(cell_height / 2.0))
				cell.terrain = img.get_pixel(x_offset + floor(cell_width / 2.0), y_offset + floor(cell_height / 2.0))
				cell.neighbors[TileSet.CELL_NEIGHBOR_RIGHT_SIDE] = img.get_pixel(x_offset + cell_width - 1, y_offset + floor(cell_height / 2.0))

				cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER] = img.get_pixel(x_offset + 0, y_offset + cell_height - 1)
				cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_SIDE] = img.get_pixel(x_offset + floor(cell_width / 2.0), y_offset + cell_height - 1)
				cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER] = img.get_pixel(x_offset + cell_width - 1, y_offset + cell_height - 1)
				
				for color: Color in [cell.terrain] + cell.neighbors.values():
					if color.a == 0.0:
						continue
					var hex_code := color.to_html()
					if !hex_codes.has(hex_code):
						hex_codes.push_back(hex_code)
						result.colors.push_back(color)

				result.cells.push_back(cell)
				
		return result
	
	static func from_tile_set(tile_set: TileSet, source_id: int, terrainColorToId: Dictionary[String, int]) -> BitMaskImageParseResult:
		var source: TileSetAtlasSource = tile_set.get_source(source_id)
		
		var result = BitMaskImageParseResult.new()
		result.colors = [] as Array[Color]
		result.cells = [] as Array[BitMaskImageCell]

		var source_size := source.get_atlas_grid_size()
		result.size = source_size
		
		var hex_codes: Array[String] = []
		for y in range(result.size.y):
			for x in range(result.size.x):
				var cell = BitMaskImageCell.new()
				cell.coords = Vector2(x, y)

				var data := source.get_tile_data(cell.coords, 0)
				
				cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER))
				cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_SIDE] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE))
				cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER))
				
				cell.neighbors[TileSet.CELL_NEIGHBOR_LEFT_SIDE] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE))
				cell.terrain = tile_set.get_terrain_color(data.terrain_set, data.terrain)
				cell.neighbors[TileSet.CELL_NEIGHBOR_RIGHT_SIDE] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE))

				cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER))
				cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_SIDE] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
				cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER] = tile_set.get_terrain_color(data.terrain_set, data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER))
				
				for color: Color in [cell.terrain] + cell.neighbors.values():
					if color.a == 0.0:
						continue
					var hex_code := color.to_html()
					if !hex_codes.has(hex_code):
						hex_codes.push_back(hex_code)
						result.colors.push_back(color)
				
				result.cells.push_back(cell)
				
		return result

	func to_image() -> Image:
		var img = Image.create(size.x * 3, size.y * 3, false, Image.Format.FORMAT_RGBA8)
		for cell in cells:
			var x = cell.coords.x
			var y = cell.coords.y
	
			var x_offset = x * 3
			var y_offset = y * 3

			img.set_pixel(x_offset, y_offset, cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER])
			img.set_pixel(x_offset + 1, y_offset, cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_SIDE])
			img.set_pixel(x_offset + 2, y_offset, cell.neighbors[TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER])

			img.set_pixel(x_offset, y_offset + 1, cell.neighbors[TileSet.CELL_NEIGHBOR_LEFT_SIDE])
			img.set_pixel(x_offset + 1, y_offset + 1, cell.terrain)
			img.set_pixel(x_offset + 2, y_offset + 1, cell.neighbors[TileSet.CELL_NEIGHBOR_RIGHT_SIDE])

			img.set_pixel(x_offset, y_offset + 2, cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER])
			img.set_pixel(x_offset + 1, y_offset + 2, cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_SIDE])
			img.set_pixel(x_offset + 2, y_offset + 2, cell.neighbors[TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER])
		return img

static func prepare_terrain_set(tile_set: TileSet) -> int:
	var terrain_sets_count := tile_set.get_terrain_sets_count()

	# Add a new terrain set if there is none yet.
	if terrain_sets_count == 0:
		tile_set.add_terrain_set()
		terrain_sets_count += 1
	var terrain_set_index := terrain_sets_count - 1

	return terrain_set_index

static func build_terrain_color_map(tile_set: TileSet, terrain_set_index: int, colors: Array[Color]) -> Dictionary[String, int]:
	# Collect existing terrains from the tile set
	var terrainColorToId: Dictionary[String, int] = {}
	for terrain_index in range(tile_set.get_terrains_count(terrain_set_index)):
		var color := tile_set.get_terrain_color(terrain_set_index, terrain_index).to_html()
		terrainColorToId[color] = terrain_index
	
	# Add new terrains from the parsed image
	var new_terrain_index := tile_set.get_terrains_count(terrain_set_index)
	for terrain in colors:
		var color := terrain.to_html()
		if !terrainColorToId.has(color):
			tile_set.add_terrain(terrain_set_index)
			tile_set.set_terrain_color(terrain_set_index, new_terrain_index, terrain)
			terrainColorToId[color] = new_terrain_index
			new_terrain_index += 1
	
	return terrainColorToId

static func apply_bitmap_to_source(src: TileSetSource, terrain_set_index: int, cells: Array[BitMaskImageCell], terrainColorToId: Dictionary[String, int]) -> void:
	for cell in cells:
		var has_tile := src.has_tile(cell.coords)
		if (!has_tile): continue
		var data: TileData = src.get_tile_data(cell.coords, 0)
		
		data.terrain_set = terrain_set_index

		if terrainColorToId.has(cell.terrain.to_html()):
			data.terrain = terrainColorToId[cell.terrain.to_html()]
		else:
			data.terrain = -1
		for neighbor in cell.neighbors:
			var color = cell.neighbors[neighbor].to_html()
			if terrainColorToId.has(color):
				data.set_terrain_peering_bit(neighbor, terrainColorToId[color])
			else:
				data.set_terrain_peering_bit(neighbor, -1)

static func update_tile_map(tile_map: TileMapLayer, template: Texture2D, source: TileSetSource) -> void:
	var tile_set := tile_map.tile_set

	var result := BitMaskImageParseResult.from_image(template.get_image(), tile_set.tile_size.x, tile_set.tile_size.y)

	var terrain_set_index := prepare_terrain_set(tile_set)
	var terrainColorToId := build_terrain_color_map(tile_set, terrain_set_index, result.colors)

	apply_bitmap_to_source(source, terrain_set_index, result.cells, terrainColorToId)
