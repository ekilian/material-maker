extends Control

@export var genmask_material : ShaderMaterial
@export var ssao_material : ShaderMaterial

var model_path : String = ""
var idmap_filename : String = ""
var idmap : ImageTexture
var mask : MMTexture
var current_view_mode : int = 0

@onready var mesh_instance : MeshInstance3D = $VBoxContainer/ViewportContainer/SubViewport/MeshPivot/MeshInstance3D
@onready var camera_pivot : Node3D = $VBoxContainer/ViewportContainer/SubViewport/CameraPivot
@onready var camera : Camera3D = $VBoxContainer/ViewportContainer/SubViewport/CameraPivot/Camera3D
@onready var viewport_container : SubViewportContainer = $VBoxContainer/ViewportContainer
@onready var viewport : SubViewport = $VBoxContainer/ViewportContainer/SubViewport
@onready var texture_rect : TextureRect = $VBoxContainer/ViewportContainer/TextureRect

@onready var context_menu : PopupMenu = $ContextMenu

const CAMERA_DISTANCE_MIN = 0.5
const CAMERA_DISTANCE_MAX = 150.0
const CAMERA_FOV_MIN = 10
const CAMERA_FOV_MAX = 90


func _ready() -> void:
	mask = MMTexture.new()
	var image = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1))
	mask.set_texture(ImageTexture.create_from_image(image))
	viewport_container.visible = false
	# Create idmap texture
	idmap = ImageTexture.new()
	var image2 : Image = Image.new()
	image2.create(16, 16, 0, Image.FORMAT_RGBA8)
	image2.fill(Color(0, 0, 0))
	idmap.set_image(image2)
	PainterEventBus.subscribe("PAINT_PROJECT_LOADED", self, "on_mesh_loaded")

func on_mesh_loaded(event):
	var payload = event.info_dictionary
	init_mask(payload.mesh, payload.file_name, "")

func update_tab_title() -> void:
	if !get_parent().has_method("set_tab_title"):
		return
	var title = "[unnamed]"
	if get_parent().has_method("set_tab_title"):
		get_parent().set_tab_title(get_index(), title)


func init_mask(mesh : Mesh, mesh_filename: String, filename : String) -> void:
	if filename:
		idmap_filename = filename
	set_color_mask(0, idmap_filename)
	model_path = mesh_filename
	set_mesh(mesh)
	viewport_container.visible = true


func set_mesh(mesh : Mesh):
	var mesh_material = mesh_instance.get_surface_override_material(0)
	mesh_instance.mesh = mesh
	mesh_instance.set_surface_override_material(0, mesh_material)
	# Center the mesh and move the camera to the whole object is visible
	var aabb : AABB = mesh_instance.get_aabb()
	mesh_instance.transform.origin = -aabb.position-0.5*aabb.size
	var d : float = aabb.size.length()
	camera.transform.origin.z = 0.8*d
	viewport_container.visible = true

func set_color_mask(view_mode : int, file_name : String):
	idmap_filename = file_name
	if !file_name.is_empty():
		idmap = ImageTexture.new()
		var image : Image = Image.new()
		image.load(idmap_filename)
		idmap.set_image(image)
		_set_shader_material(0)
		viewport_container.visible = true

func _on_load_color_mask_pressed():
	var dialog = preload("res://material_maker/windows/file_dialog/file_dialog.tscn").instantiate()
	dialog.min_size = Vector2(500, 500)
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.png;PNG image file")
	var files = await dialog.select_files()
	if files.size() == 1:
		set_color_mask(0, files[0])


func update_mask_from_mouse_position(mouse_position : Vector2):
	var texture : ViewportTexture = viewport.get_texture()
	var showing_mask : bool = ( current_view_mode != 0 )
	if showing_mask:
		# Hide viewport while we capture the position
		var shader_material : ShaderMaterial = mesh_instance.get_surface_override_material(0)
		var hide_texture : ImageTexture = ImageTexture.new()
		hide_texture.set_image(viewport.get_texture().get_image())
		texture_rect.texture = hide_texture
		texture_rect.visible = true
		shader_material.set_shader_parameter("tex", idmap)
		shader_material.set_shader_parameter("mode", 0)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
	var image : Image = texture.get_image()
	mouse_position.y =  viewport.size.y - mouse_position.y
	var position_color : Color = image.get_pixelv(mouse_position)
	texture_rect.visible = false
	genmask_material.set_shader_parameter("idmap", idmap)
	genmask_material.set_shader_parameter("color", position_color)
	var renderer = await mm_renderer.request(self)
	if renderer == null:
		return
	renderer = await renderer.render_material(self, genmask_material, idmap.get_size().x)
	renderer.copy_to_texture(mask.get_texture())
	mask.set_texture(mask.get_texture())
	renderer.release(self)


func _on_ViewportContainer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			mesh_instance.rotation.y += 0.01*event.relative.x
			camera_pivot.rotation.x -= 0.01*event.relative.y
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			context_menu.popup(Rect2(get_global_mouse_position(), Vector2(0, 0)))
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.is_command_or_control_pressed():
				camera.fov = clamp(camera.fov + 1, CAMERA_FOV_MIN, CAMERA_FOV_MAX)
			else:
				zoom(1.0 / (1.01 if event.shift_pressed else 1.1))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.is_command_or_control_pressed():
				camera.fov = clamp(camera.fov - 1, CAMERA_FOV_MIN, CAMERA_FOV_MAX)
			else:
				zoom(1.01 if event.shift_pressed else 1.1)
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT and idmap_filename != "":
			update_mask_from_mouse_position(viewport_container.get_local_mouse_position())


func _on_size_changed():
	$VBoxContainer.size = size
	
func zoom(amount : float):
	camera.position.z = clamp(camera.position.z*amount, CAMERA_DISTANCE_MIN, CAMERA_DISTANCE_MAX)

func _on_reset_pressed() -> void:
	var image : Image = Image.create_empty(16, 16, 0, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1))
	var tex = mask.get_texture()
	if tex != null:
		tex.set_image(image)
		mask.set_texture(mask.get_texture())
		_set_shader_material(0)


func _on_context_menu_id_pressed(id: int) -> void:
	if id == 3:
		print("do")
	elif id == 4:
		print("x")
	elif id == 5:
		_change_material_to_ssao()
	else:
		_set_shader_material(id)


func _set_shader_material(view_mode: int) -> void:
	var material : ShaderMaterial = mesh_instance.get_surface_override_material(0)
	current_view_mode = view_mode
	material.set_shader_parameter("tex", idmap)
	material.set_shader_parameter("mask", mask.get_texture())
	material.set_shader_parameter("mode", current_view_mode)

func _change_material_to_ssao() -> void:
	mesh_instance.set_surface_override_material(0, ssao_material)
