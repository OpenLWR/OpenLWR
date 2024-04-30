shader_type spatial;

uniform sampler2D rod_statuses;
uniform sampler2D rod_enabled;
uniform sampler2D rod_texts;

uniform bool blink;

const vec4 TYPES = vec4(14.0, 15.0, 2.0, 1.0);
const vec3 FULL_IN = vec3(0.0, 1.0, 0.0);
const vec3 FULL_OUT = vec3(1.0, 0.0, 0.0);

const vec3 SELECTED = vec3(1.0);
const vec3 DRIFT = vec3(1.0, 0.0, 0.0);
const vec3 ACCUM = vec3(1.0, 0.53, 0.0);
const vec3 SCRAM = vec3(0.0, 0.0, 1.0);

const vec3 LPRM_UPSCALE = vec3(1.0, 0.53, 0.0);
const vec3 LPRM_DOWNSCALE = vec3(1.0, 0.53, 0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

uvec4 getRod(in ivec2 rod) {
	return uvec4(texelFetch(rod_statuses, rod, 0) * TYPES);
}

vec4 getRodColor(in uvec4 rod_map, in vec2 sub_uv) {
	vec2 TEXTS_SIZE = vec2(textureSize(rod_texts, 0));
	return texelFetch(rod_texts, ivec2((vec2(rod_map.xy) + sub_uv) * TEXTS_SIZE / vec2(14.0, 15.0)), 0);
}

bool getRodEnabled(in ivec2 rod) {
	return blink;
	return texelFetch(rod_enabled, rod, 0).x > 0.5;
}

bool shouldFlash(in uvec4 rod_status) {
	return false;
	return rod_status.b > 0u;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	ivec2 RODS = textureSize(rod_statuses, 0);
	ivec2 rod = ivec2(UV.yx * vec2(RODS));
	rod = ivec2(1, -1) * rod + ivec2(0, 1) * RODS + ivec2(0,-1);
	vec2 sub_UV = mod((vec2(0, 1) + vec2(1, -1) * UV.yx) * vec2(RODS), 1.0);
	uvec4 rod_status = getRod(rod);
	
	vec4 col = getRodColor(rod_status, sub_UV);
	EMISSION = col.rgb * ((!shouldFlash(rod_status) || mod(TIME, 0.2) < 0.1) && getRodEnabled(rod) ? 1.0 : 0.0);
	ALBEDO = col.rgb * 0.2;
	ALPHA = col.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
