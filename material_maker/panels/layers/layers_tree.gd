class_name LayersTree
extends Tree

const ICON_LAYER_PAINT = preload("res://material_maker/panels/layers/icons/layer_paint.tres")
const ICON_LAYER_PROC = preload("res://material_maker/panels/layers/icons/layer_proc.tres")
const ICON_LAYER_MASK = preload("res://material_maker/panels/layers/icons/layer_mask.tres")
const ICONS = [ ICON_LAYER_PAINT, ICON_LAYER_PROC, ICON_LAYER_MASK ]

const BUTTON_SHOWN = preload("res://material_maker/panels/layers/icons/visible.tres")
const BUTTON_HIDDEN = preload("res://material_maker/panels/layers/icons/not_visible.tres")
const BUTTON_CONFIG = preload("res://material_maker/panels/layers/icons/config.tres")
const BUTTON_CONFIG_ACTIVE = preload("res://material_maker/panels/layers/icons/config_active.tres")

var layers = null
var selected_item : TreeItem = null
var just_selected : bool = false

signal selection_changed(old_selected, new_selected)

func _ready():
	set_column_expand(1, false)
	set_column_custom_minimum_width(1, 60)

func _make_custom_tooltip(for_text):
	if for_text == "":
		return null
	var project_panel = mm_globals.main_window.get_current_project()
	var panel = preload("res://material_maker/panels/layers/layer_tooltip.tscn").instantiate()
	var item : TreeItem = instance_from_id(int(for_text)) as TreeItem
	if item:
		panel.set_layer(item.get_meta("layer"), project_panel.get_settings())
	return panel

func update_from_layers(layers_array : Array, selected_layer) -> void:
	selected_item = null
	clear()
	do_update_from_layers(layers_array, create_item(), selected_layer)

func do_update_from_layers(layers_array : Array, item : TreeItem, selected_layer) -> void:
	for l in layers_array:
		var new_item = create_item(item)
		new_item.set_text(0, l.name)
		new_item.set_icon(0, ICONS[l.get_layer_type()])
		if l.get_layer_type() != MMLayer.LAYER_MASK:
			new_item.add_button(1, BUTTON_CONFIG_ACTIVE if l.has_custom_config() else BUTTON_CONFIG, 1)
		new_item.add_button(1, BUTTON_HIDDEN if l.hidden else BUTTON_SHOWN, 2, false, str(new_item.get_instance_id()))
		new_item.set_editable(0, false)
		new_item.set_meta("layer", l)
		if l == selected_layer:
			new_item.select(0)
			selected_item = new_item
		do_update_from_layers(l.layers, new_item, selected_layer)


func force_update_from_layers() -> void:
	update_from_layers(layers.layers, selected_item)


func get_item_index(item : TreeItem) -> int:
	var rv : int = 0
	while item.get_prev() != null:
		item = item.get_prev()
		rv += 1
	return rv


func _on_Tree_button_pressed(item : TreeItem, _column : int, _id : int, _button_index : int):
	match _id:
		1: 
			print("TODO: Switch to clicked not selected")
			var current = get_selected()
			if current != null:
				var layer : MMLayer = current.get_meta("layer")
				if layer.get_layer_type() == MMLayer.LAYER_MASK:
					return
				var project_panel = mm_globals.main_window.get_current_project()
				var popup = preload("res://material_maker/panels/layers/layer_config_popup.tscn").instantiate()
				add_child(popup)
				popup.configure_layer(layers, current.get_meta("layer"), self, project_panel.get_settings())
		2:
			var layer = item.get_meta("layer")
			layer.hidden = not layer.hidden
			_on_layers_changed()

func _on_Tree_cell_selected():
	just_selected = true
	if selected_item != null:
		selected_item.set_editable(0, false)
	if selected_item != get_selected():
		emit_signal("selection_changed", selected_item, get_selected())

func _on_Tree_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and selected_item != null and just_selected:
		selected_item.set_editable(0, true)
		just_selected = false

func _on_Tree_item_edited():
	selected_item.get_meta("layer").name = selected_item.get_text(0)

func _on_layers_changed():
	layers._on_layers_changed()

#
# Drag and drop
#
func _get_drag_data(_position : Vector2):
	var layer = get_selected().get_meta("layer")
	var label : Label = Label.new()
	label.text = layer.name
	set_drag_preview(label)
	return get_selected()

	
func _drop_data(pos : Vector2, data):
	var target_item : TreeItem = get_item_at_position(pos)
	if data != null and target_item != null and !item_is_child(target_item, data):
		var layer = data.get_meta("layer")
		match get_drop_section_at_position(pos):
			0:
				layers.move_layer_into(layer, target_item.get_meta("layer"))
			-1:
				if target_item.get_parent() != null:
					layers.move_layer_into(layer, target_item.get_parent().get_meta("layer"), get_item_index(target_item))
				else:
					print("Cannot move item")
			1:
				if target_item.get_parent() != null:
					layers.move_layer_into(layer, target_item.get_parent().get_meta("layer"), get_item_index(target_item)+1)
				else:
					print("Cannot move item")
		_on_layers_changed()


func _can_drop_data(pos : Vector2, data):
	drop_mode_flags = DROP_MODE_ON_ITEM | DROP_MODE_INBETWEEN
	var target_item = get_item_at_position(pos)
	if target_item != null and !item_is_child(target_item, data):
		return true
	return false


func item_is_child(i1 : TreeItem, i2 : TreeItem):
	while i1 != null:
		if i1 == i2:
			return true
		i1 = i1.get_parent()
	return false
