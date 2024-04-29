shader_type spatial;

uniform sampler2D rod_statuses;
uniform sampler2D rod_enabled;
uniform sampler2D rod_texts;

uniform bool blink;

const vec4 TYPES = vec4(9.0) - 1.0;
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

bool getRodEnabled(in ivec2 rod) {
	return blink;
	return texelFetch(rod_enabled, rod, 0).x > 0.5;
}

bool shouldFlash(in uvec4 rod_status) {
	return rod_status.x < 6u;
}

void fragment() {
	// Called for every pixel the material is visible on.
	//ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	ivec2 RODS = textureSize(rod_statuses, 0);
	ivec2 rod = ivec2(UV.yx * vec2(RODS));
	rod = ivec2(1, -1) * rod + ivec2(0, 1) * RODS + ivec2(0,-1);
	vec2 sub_UV = UV.yx * vec2(RODS) - vec2(rod);
	uvec4 rod_status = getRod(rod);
	
	vec3 col;
	
	switch (rod_status.x) {
		case 0u:
			ALPHA = 0.0;
			break;
		case 1u:
			col = FULL_IN;
			break;
		case 2u:
			col = FULL_OUT;
			break;
		case 3u:
			col = SELECTED;
			break;
		case 4u:
			col = LPRM_UPSCALE;
			break;
		case 5u:
			col = LPRM_DOWNSCALE;
			break;
		case 6u:
			col = DRIFT;
			break;
		case 7u:
			col = ACCUM;
			break;
		case 8u:
			col = SCRAM;
			break;
	}
	EMISSION = col * ((shouldFlash(rod_status) || mod(TIME, 0.2) < 0.1) && getRodEnabled(rod) ? 1.0 : 0.0);
	ALBEDO = col * 0.2;
	ALPHA = ALPHA * 0.5;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
