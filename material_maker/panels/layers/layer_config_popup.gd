extends PopupPanel

const OFFSET : int = 10

var paint_layers : Node
var layer : Object
var changed : bool = false
var tree : LayersTree

func configure_layer(layers : Node, l : Object, parent : LayersTree, settings : Dictionary) -> void:
	tree = parent
	paint_layers = layers
	layer = l
	$GridContainer/Albedo.set_value(l.albedo_alpha)
	$GridContainer/Metallic.set_value(l.metallic_alpha)
	$GridContainer/Roughness.set_value(l.roughness_alpha)
	$GridContainer/Emission.set_value(l.emission_alpha)
	$GridContainer/Normal.set_value(l.normal_alpha)
	$GridContainer/Depth.set_value(l.depth_alpha)
	$GridContainer/Occlusion.set_value(l.occlusion_alpha)
	
	if !settings.paint_emission :
		$GridContainer/Emission.mode = FloatEdit.Modes.INACTIVE
	if !settings.paint_normal :	
		$GridContainer/Normal.mode = FloatEdit.Modes.INACTIVE
	if !settings.paint_depth :
		$GridContainer/Depth.mode = FloatEdit.Modes.INACTIVE
		$GridContainer/Occlusion.mode = FloatEdit.Modes.INACTIVE
		
	var mouse_pos = $GridContainer.get_global_mouse_position()
	var display_size = DisplayServer.screen_get_size()
	print($GridContainer.get_minimum_size())
	
	if (display_size.x - mouse_pos.x) < $GridContainer.get_minimum_size().x:
		var first = Vector2($GridContainer.get_global_mouse_position().x - ($GridContainer.get_minimum_size().x + OFFSET), $GridContainer.get_global_mouse_position().y)
		popup(Rect2(first, $GridContainer.get_minimum_size()))
	else:
		popup(Rect2($GridContainer.get_global_mouse_position(), $GridContainer.get_minimum_size()))


func _on_LayerConfigPopup_popup_hide():
	if changed:
		tree.force_update_from_layers()
	queue_free()

func _on_value_changed(value, channel):
	layer.set_alpha(channel, value)
	paint_layers.update_alpha(channel)
	paint_layers._on_Painter_painted()
	changed = true
	
	
