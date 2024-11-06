shader_type spatial;

varying vec3 vertex_normal;

uniform vec3 samples[64];
uniform int kernelSize = 64;
uniform float radius = 0.5;
uniform float bias = 0.025;

uniform int num_noise = 4; // if this is changed so should the array size below
uniform vec3 noises[4];

uniform sampler2D random_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture ;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

vec3 getPosition(vec2 uv, mat4 inv_proj_matrix, mat4 inv_view_matrix) 
{
// Get the pixel position in view space
float depth = textureLod(DEPTH_TEXTURE, uv, 0.0).r;
vec4 temp = inv_proj_matrix * vec4(uv * 2.0 - 1.0, depth, 1.0);
vec3 pixel_position_view = temp.xyz / temp.w;
// Get the pixel position in world space
temp = (inv_view_matrix * vec4(pixel_position_view , 1.0));
vec3 pixel_position_world = temp.xyz / temp.w;
return pixel_position_world;
}

void fragment() {
vec2 uv = SCREEN_UV;
vec3 pixel_position_world = getPosition(uv, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);

vec2 noiseScale = vec2(VIEWPORT_SIZE.x/float(num_noise), VIEWPORT_SIZE.y/float(num_noise));
vec3 randomVec = normalize(texture(random_texture, uv * noiseScale).rgb);

vec3 normal = normalize(texture(NORMAL_TEXTURE, uv).rgb);
vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
mat3 TBN = mat3(tangent, cross(normal, tangent), normal);

float occlusion = 0.0;
for(int i = 0; i < kernelSize; ++i)
    {
        // get sample position
        vec3 samplePos = TBN * samples[i]; // from tangent to view-space
        samplePos = pixel_position_world + samplePos * radius; // <- is this in world space?

        // project sample position (to sample texture) (to get position on screen/texture)
        vec4 offset = vec4(samplePos, 1.0);
        offset = PROJECTION_MATRIX * offset; // from view to clip-space
        offset.xyz /= offset.w; // perspective divide
        offset.xyz = offset.xyz * 0.5 + 0.5; // transform to range 0.0 - 1.0

        // get sample depth
        float sampleDepth = getPosition(offset.xy, INV_PROJECTION_MATRIX, INV_VIEW_MATRIX).z; // get depth value of kernel sample

        // range check & accumulate
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(pixel_position_world.z - sampleDepth));
        occlusion += (sampleDepth >= samplePos.z + bias ? 1.0 : 0.0) * rangeCheck;
    }
    occlusion = 1.0 - (occlusion / float(kernelSize));

vec4 screen_color = texture(SCREEN_TEXTURE, uv);
ALBEDO = mix(screen_color.rgb, vec3(occlusion), 0.5); 
}