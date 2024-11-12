extends PanelContainer


@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer


enum PreviewSizes { SMALL=0, MEDIUM=1, LARGE=2 }
var PREVIEW_SIZE_DEF = {
	PreviewSizes.SMALL:Vector2i(128, 128),
	PreviewSizes.MEDIUM:Vector2i(256, 256),
	PreviewSizes.LARGE:Vector2i(512, 512)
}
var preview_size:PreviewSizes = PreviewSizes.SMALL


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func on_layer_selected(layer: MMLayer) -> void:
	_clear_grid()
	
	var preloaded = preload("res://material_maker/panels/preview_paint/preview_tab.tscn")
	for channel in layer.get_channels():
		if channel == "mr" or channel == "do":
			var preview = preloaded.instantiate()
			preview.set_custom_minimum_size(PREVIEW_SIZE_DEF[preview_size])
			grid_container.add_child(preview)
			preview.init_mr(layer, channel, "m")
			
			preview = preloaded.instantiate()
			preview.set_custom_minimum_size(PREVIEW_SIZE_DEF[preview_size])
			grid_container.add_child(preview)
			preview.init_mr(layer, channel, "r")
		else:
			var preview = preloaded.instantiate()
			preview.set_custom_minimum_size(PREVIEW_SIZE_DEF[preview_size])
			grid_container.add_child(preview)
			preview.init(layer, channel)


func _clear_grid() -> void:
	for node in grid_container.get_children():
		grid_container.remove_child(node)
		node.queue_free()

func _on_size_pressed(index: int) -> void:
	preview_size = index
	for cell in grid_container.get_children():
		cell.set_custom_minimum_size(PREVIEW_SIZE_DEF[preview_size])
