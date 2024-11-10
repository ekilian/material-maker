extends ScrollContainer

@onready var project_button = $ScrollContainer/CollapseContainer/ProjectPanel/Margin/Container/ProjectButton
@onready var layer_button = $CollapseContainer/LayerPanel/Margin/Container/LayerButton
@onready var brush_button = $CollapseContainer/BrushPanel/PanelContainer/VBoxContainer/BrushButton

@onready var brush_parameters: GridContainer = $CollapseContainer/BrushPanel/PanelContainer/VBoxContainer/Margin/BrushParameters
@onready var project_parameters: GridContainer = $CollapseContainer/ProjectPanel/Margin/Container/Margin/ProjectSettings
@onready var layer_parameters: GridContainer = $CollapseContainer/LayerPanel/Margin/Container/Margin/LayerConfigs


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_generator(generator) -> void:
	#Why is it null?
	if brush_parameters:
		brush_parameters.set_generator(generator)

func set_project(settings:Dictionary) -> void:
	if project_parameters:
		project_parameters.set_project(settings)

func on_layer_selected(layer) -> void:
	if layer == null:
		layer_button._on_toggled(false)
		brush_button._on_toggled(false)
	elif layer_parameters:
		layer_button._on_toggled(true)
		layer_parameters.set_layer(layer)
		if layer.get_layer_type() != MMLayer.LAYER_MASK:
			brush_button._on_toggled(true)
