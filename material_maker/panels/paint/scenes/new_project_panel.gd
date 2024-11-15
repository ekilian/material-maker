extends PanelContainer

@onready var paint_emission = $Darken/VBoxContainer/Settings/Panel/VBoxContainer/Margin/Grid/PaintEmission
@onready var paint_normal = $Darken/VBoxContainer/Settings/Panel/VBoxContainer/Margin/Grid/PaintNormal
@onready var paint_depth = $Darken/VBoxContainer/Settings/Panel/VBoxContainer/Margin/Grid/PaintDepth
@onready var paint_bump = $Darken/VBoxContainer/Settings/Panel/VBoxContainer/Margin/Grid/Bump/PaintBump
@onready var paint_bump_value = $Darken/VBoxContainer/Settings/Panel/VBoxContainer/Margin/Grid/Bump/BumpStrength
@onready var resolution = $Darken/VBoxContainer/Settings/Panel/VBoxContainer/Margin/Grid/Resolution/Resolution

@onready var model_file = $Darken/VBoxContainer/Project/Panel/VBoxContainer/Margin/Grid/ModelFile
@onready var project_filename = $Darken/VBoxContainer/Project/Panel/VBoxContainer/Margin/Grid/ProjectName
@onready var mask_file = $Darken/VBoxContainer/Optionals/Panel/VBoxContainer/Margin/Grid/ChooseFile


signal project_created(project: Dictionary)
signal model_selected(file_name:String)


func _ready() -> void:
	#TODO: Get Defaults from Paint-Preferences
	paint_emission.button_pressed = true
	paint_normal.button_pressed = true
	paint_depth.button_pressed = true
	paint_bump.button_pressed = true
	paint_bump_value.value = 0.5
	mask_file


func _on_start_project_pressed() -> void:
	var project = { 
			model=model_file.text, 
			project_filename=project_filename.text,
			idmap=mask_file.text,
			settings={
				paint_emission=paint_emission.button_pressed,
				paint_normal=paint_normal.button_pressed,
				paint_depth=paint_depth.button_pressed,
				paint_depth_as_bump = paint_bump.button_pressed,
				bump_strength=paint_bump_value.value,
				texture_size=pow(2, resolution.size_value)
			}
		}
	emit_signal("project_created", project)
	var tween = create_tween();
	tween.tween_property(self, "position:x", -500, 0.5)
	tween.tween_callback(queue_free)


func _on_choose_model_pressed():
	var dialog = _get_file_dialog(["*.glb,*.gltf;GLTF file", "*.obj;Wavefront OBJ file"])
	var files = await dialog.select_files()
	#TODO Handle file selected
	if files.size() == 1:
		model_file.text = files[0]
		model_selected.emit(model_file.text)
		project_filename.text = model_file.text.get_file()+".mmpp"
	await get_tree().process_frame
	if model_file.text && project_filename.text:
		%Start.disabled = false


func _on_choose_color_id_file_pressed() -> void:
	var dialog = _get_file_dialog(["*.png;PNG image file"])
	var files = await dialog.select_files()
	if files.size() == 1:
		mask_file.text = files[0]


func _get_file_dialog(filters: Array) -> FileDialog:
	var file_dialog = preload("res://material_maker/windows/file_dialog/file_dialog.tscn").instantiate()
	file_dialog.min_size = Vector2(500, 500)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	for filter in filters:
		file_dialog.add_filter(filter);
	return file_dialog


func _on_project_name_focus_exited() -> void:
	if model_file.text && project_filename.text:
		%Start.disabled = false
