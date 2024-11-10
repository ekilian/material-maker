extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_layer(layer) -> void:
	$Albedo.set_value(layer.albedo_alpha)
	$Metallic.set_value(layer.metallic_alpha)
	$Roughness.set_value(layer.roughness_alpha)
	$Emission.set_value(layer.emission_alpha)
	$Normal.set_value(layer.normal_alpha)
	$Depth.set_value(layer.depth_alpha)
	$Occlusion.set_value(layer.occlusion_alpha)
