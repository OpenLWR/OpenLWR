shader_type spatial;

#define FETCH_METHOD 2

uniform sampler2D rods;
uniform sampler2D rod_texts;

const vec4 TYPES = vec4(14.0, 15.0, 3.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

uvec4 getRod(in ivec2 rod) {
	return uvec4(texelFetch(rods, rod, 0) * TYPES);
}

vec4 getRodColor(in uvec4 rod_map, in vec2 sub_uv, in float z) {
	#if FETCH_METHOD == 0
		vec2 abs_sub_uv = abs(sub_uv - 0.5);
		float lod_bias = (abs_sub_uv.x > 0.4 || abs_sub_uv.y > 0.4) ? -999.0e9 : -1.0;
		return texture(rod_texts, vec2((vec2(rod_map.xy) + sub_uv) / TYPES.xy), lod_bias);
	#elif FETCH_METHOD == 1
		return textureLod(rod_texts, vec2((vec2(rod_map.xy) + sub_uv) / TYPES.xy), 0.0);
	#elif FETCH_METHOD == 2
		vec2 TEXTS_SIZE = vec2(textureSize(rod_texts, 0));
		return texelFetch(rod_texts, ivec2((vec2(rod_map.xy) + sub_uv) * TEXTS_SIZE / TYPES.xy), 0);
	#endif //FETCH_METHOD
}

bool getRodEnabled(in uvec4 rod_status) {
	//return true;
	return rod_status.b > 0u;
}

bool shouldFlash(in uvec4 rod_status) {
	return rod_status.b == 2u;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	ivec2 RODS = textureSize(rods, 0);
	ivec2 rod = ivec2(UV * vec2(RODS));
	vec2 sub_UV = mod(UV * vec2(RODS), 1.0);
	uvec4 rod_status = getRod(rod);
	
	vec4 col = getRodColor(rod_status, sub_UV, FRAGCOORD.z);
	EMISSION = col.rgb * ((!shouldFlash(rod_status) || mod(TIME, 0.2) < 0.1) && getRodEnabled(rod_status) ? 1.0 : 0.0);
	ALBEDO = vec3(length(col.rgb) > 0.5 ? 0.4 : 0.0);
	//ALPHA = col.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
