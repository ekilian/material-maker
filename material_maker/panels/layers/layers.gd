extends PanelContainer

## Main class for the 'Layers' panel.
##
## Emits:
##	Group-Signals:		on_layer_selected
## Consumes:
##	Group-Signals:		PaintLayers->set_layers
##


var paint_layers: PaintLayers

@onready var tree: Tree = %Tree


func _ready():
	var popup : PopupMenu = %Buttons/Add.get_popup()
	popup.id_pressed.connect(_on_add_layer_menu)
	#set_layers(layers)

func set_layers(layers: PaintLayers) -> void:
	self.paint_layers = layers
	if paint_layers and tree:
		tree.layers = paint_layers
		tree.update_from_layers(paint_layers.layers, paint_layers.selected_layer)

func _on_Tree_selection_changed(_old_selected : TreeItem, new_selected : TreeItem) -> void:
	var meta_data = new_selected.get_meta("layer")
	if meta_data != null:
		if meta_data is not String:
			paint_layers.select_layer(meta_data)
		get_tree().call_group("layers", "on_layer_selected", meta_data)

func _on_add_layer_menu(id):
	paint_layers.add_layer(id)
	paint_layers.get_parent().initialize_layers_history()

func _on_Duplicate_pressed():
	var current = tree.get_selected()
	if current != null:
		paint_layers.duplicate_layer(current.get_meta("layer"))
	paint_layers.get_parent().initialize_layers_history()

func _on_Remove_pressed():
	var current = tree.get_selected()
	if current != null:
		paint_layers.remove_layer(current.get_meta("layer"))

func _on_Up_pressed():
	var current = tree.get_selected()
	if current != null:
		paint_layers.move_layer_up(current.get_meta("layer"))

func _on_Down_pressed():
	var current = tree.get_selected()
	if current != null:
		paint_layers.move_layer_down(current.get_meta("layer"))
