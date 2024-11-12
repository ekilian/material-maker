class_name MPColorRect
extends Object

static func Create(size: Vector2i, color: Color) -> ColorRect:
	var new_instance = ColorRect.new()
	new_instance.size = size
	new_instance.color = color
	return new_instance
	
	
static func CreateWithMaterial(size: Vector2i, shader: Shader, texture: Texture2D, alpha: float) -> ColorRect:
	var new_instance = ColorRect.new()
	new_instance.size = size
	new_instance.material = ShaderMaterial.new()
	new_instance.material.shader = shader
	new_instance.material.set_shader_parameter("input_tex", texture)
	new_instance.material.set_shader_parameter("modulate", alpha)
	return new_instance
