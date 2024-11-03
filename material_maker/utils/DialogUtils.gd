class_name DialogUtils
extends Reference

static func create_file_dialog(dialog:Variant) -> String:
	dialog.min_size = Vector2(500, 500)
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.add_filter("*.png;PNG image file")
	var files = await dialog.select_files()
    if files.size() != 1:
        return files[0]
    return null