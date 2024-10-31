extends PanelContainer

func _ready():
	pass # Replace with function body.

func set_layer(l, settings:Dictionary) -> void:
	$VBoxContainer/LayerName.text = l.name
	var thumbnail_scene = preload("res://material_maker/panels/layers/layer_tooltip_thumbnail.tscn")
	for c in l.get_channels():
		if check_if_layer_is_visible(c, settings):
			if c == "mr" or c == "do":
				var t = thumbnail_scene.instantiate()
				t.init_mr(l, c, "m", "metallic" if c == "mr" else "depth")
				$VBoxContainer/Thumbnails.add_child(t)
				t = thumbnail_scene.instantiate()
				t.init_mr(l, c, "r", "roughness" if c == "mr" else "occlusion")
				$VBoxContainer/Thumbnails.add_child(t)
			else:
				var t = thumbnail_scene.instantiate()
				t.init(l, c)
				$VBoxContainer/Thumbnails.add_child(t)


func check_if_layer_is_visible(c, settings) -> bool:
	if c == "albedo" or c == "mr":
		return true;

	match c:
		"emission":
			return settings.paint_emission
		"normal":
			return settings.paint_normal
		"do":
			return settings.paint_depth
		
	return false;
