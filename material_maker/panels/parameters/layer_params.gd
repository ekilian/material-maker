extends GridContainer

var is_mask : bool = false
var current_layer : MMLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_layer(layer) -> void:
	current_layer = layer
	$Albedo.set_value(layer.albedo_alpha)
	$Metallic.set_value(layer.metallic_alpha)
	$Roughness.set_value(layer.roughness_alpha)
	$Emission.set_value(layer.emission_alpha)
	$Normal.set_value(layer.normal_alpha)
	$Depth.set_value(layer.depth_alpha)
	$Occlusion.set_value(layer.occlusion_alpha)

func set_is_mask(value : bool) -> void:
	is_mask = value;
	self.visible = !is_mask


func _on_value_changed(value: Variant, channel: String) -> void:
	current_layer.set_alpha(channel, value)
	get_tree().call_group("layers", "_on_layers_settings_changed", channel, value)
