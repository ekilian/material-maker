extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func set_project(settings:Dictionary) -> void:
	$SizeOptionButton.size_value = settings.texture_size
	$PaintEmission.button_pressed = settings.paint_emission
	$PaintNormal.button_pressed = settings.paint_normal
	$PaintDepth.button_pressed = settings.paint_depth
	$PaintBump.button_pressed = settings.paint_depth_as_bump
	$BumpStrength.value = settings.bump_strength

func _on_value_changed() ->void:
	pass
	#TODO: Fire Event
