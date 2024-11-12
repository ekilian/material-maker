extends ScrollContainer

@onready var project_button = $CollapseContainer/ProjectPanel/Margin/Container/ProjectButton
@onready var layer_button = $CollapseContainer/LayerPanel/Margin/Container/LayerButton
@onready var brush_button = $CollapseContainer/BrushPanel/PanelContainer/VBoxContainer/BrushButton

@onready var brush_parameters: GridContainer = $CollapseContainer/BrushPanel/PanelContainer/VBoxContainer/Margin/BrushParameters
@onready var project_parameters: GridContainer = $CollapseContainer/ProjectPanel/Margin/Container/Margin/ProjectSettings
@onready var layer_parameters: GridContainer = $CollapseContainer/LayerPanel/Margin/Container/Margin/LayerConfigs


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var project = mm_globals.main_window.get_current_project()
	if project:
		set_project(project.get_settings())


func set_generator(generator) -> void:
	#Why is it null?
	if brush_parameters:
		brush_parameters.set_generator(generator)

func set_project(settings:Dictionary) -> void:
	if project_parameters:
		project_parameters.set_project_settings(settings)

func on_layer_selected(layer) -> void:
	if layer is not MMLayer:
		return
	
	if layer.get_layer_type() == MMLayer.LAYER_NONE:
		$CollapseContainer/ProjectPanel.visible = true
		$CollapseContainer/LayerPanel.visible = false
		$CollapseContainer/BrushPanel.visible = false
		project_button._on_toggled(true)
		return
	
	$CollapseContainer/ProjectPanel.visible = false
	$CollapseContainer/LayerPanel.visible = true
	$CollapseContainer/BrushPanel.visible = true
	if layer.get_layer_type() == MMLayer.LAYER_MASK:
		brush_button._on_toggled(false)
		layer_button._on_toggled(false)
		layer_parameters.set_is_mask(true)
	else:
		brush_button._on_toggled(true)
		layer_button._on_toggled(true)
		if layer_parameters:
			layer_parameters.set_layer(layer)
			layer_parameters.set_is_mask(false)
