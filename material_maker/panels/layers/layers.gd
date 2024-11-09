extends Control

# The layer object
var layers

@onready var tree = %Tree


func _ready():
	var popup : PopupMenu = %Buttons/Add.get_popup()
	popup.id_pressed.connect(_on_add_layer_menu)
	set_layers(layers)

func set_layers(l) -> void:
	layers = l
	if layers and tree:
		tree.layers = l
		tree.update_from_layers(layers.layers, layers.selected_layer)

func _on_Tree_selection_changed(_old_selected : TreeItem, new_selected : TreeItem) -> void:
	layers.select_layer(new_selected.get_meta("layer"))

func _on_add_layer_menu(id):
	layers.add_layer(id)
	layers.get_parent().initialize_layers_history()

func _on_Duplicate_pressed():
	var current = tree.get_selected()
	if current != null:
		layers.duplicate_layer(current.get_meta("layer"))
	layers.get_parent().initialize_layers_history()

func _on_Remove_pressed():
	var current = tree.get_selected()
	if current != null:
		layers.remove_layer(current.get_meta("layer"))

func _on_Up_pressed():
	var current = tree.get_selected()
	if current != null:
		layers.move_layer_up(current.get_meta("layer"))

func _on_Down_pressed():
	var current = tree.get_selected()
	if current != null:
		layers.move_layer_down(current.get_meta("layer"))

func _on_Config_pressed():
	var current = tree.get_selected()
	if current != null:
		var layer : MMLayer = current.get_meta("layer")
		if layer.get_layer_type() == MMLayer.LAYER_MASK:
			return
		var popup = preload("res://material_maker/panels/layers/layer_config_popup.tscn").instantiate()
		add_child(popup)
		popup.configure_layer(layers, current.get_meta("layer"))
