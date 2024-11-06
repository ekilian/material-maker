shader_type canvas_item;

uniform sampler2D idmap;
uniform vec4      color;
uniform float     mm_chunk_size = 1.0;
uniform vec2      mm_chunk_offset = vec2(0.0);

void fragment() {
	vec3 id = texture(idmap, mm_chunk_offset+mm_chunk_size*UV).rgb;
	COLOR = vec4(vec3(step(length(id-color.rgb), 0.05)), 1.0);
}