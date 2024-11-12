extends AspectRatioContainer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	pass


func init(layer: MMLayer, channel : String) -> void:
	color_rect.tooltip_text = channel
	color_rect.material.set_shader_parameter("tex", layer.get(channel))

func init_mr(layer, channel : String, element : String) -> void:
	color_rect.tooltip_text = channel
	color_rect.material.shader = load("res://material_maker/panels/preview_paint/shaders/preview_paint_"+element+".gdshader")
	color_rect.material.set_shader_parameter("tex", layer.get(channel))
