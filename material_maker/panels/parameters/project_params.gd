extends GridContainer


var settings:Dictionary


func set_project_settings(settings:Dictionary) -> void:
	self.settings = settings
	$SizeOptionButton.size_value = settings.texture_size
	$PaintEmission.button_pressed = settings.paint_emission
	$PaintNormal.button_pressed = settings.paint_normal
	$PaintDepth.button_pressed = settings.paint_depth
	$PaintBump.button_pressed = settings.paint_depth_as_bump
	$BumpStrength.value = settings.bump_strength


func _on_paint_emission_pressed() -> void:
	settings.paint_emission = $PaintEmission.button_pressed
	_send_group_signal()

func _on_paint_normal_pressed() -> void:
	settings.paint_normal = $PaintNormal.button_pressed
	_send_group_signal()

func _on_paint_depth_pressed() -> void:
	settings.paint_depth = $PaintDepth.button_pressed
	_send_group_signal()

func _on_paint_bump_pressed() -> void:
	settings.paint_depth_as_bump = $PaintBump.button_pressed
	_send_group_signal()

func _on_size_option_button_size_value_changed(s: Variant) -> void:
	settings.texture_size = $SizeOptionButton.size_value
	_send_group_signal()

func _on_bump_strength_value_changed(value: Variant) -> void:
	settings.bump_strength = $BumpStrength.value
	_send_group_signal()

func _send_group_signal() -> void:
	get_tree().call_group("layers", "_on_project_settings_changed", settings)
