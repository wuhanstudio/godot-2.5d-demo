shader_type spatial;
render_mode
		blend_add,
		unshaded,
		world_vertex_coords;
		
uniform float camera_offset = 0.0;

uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;  
uniform vec4 albedo : source_color;


void vertex() {
	vec3 cam_dir = CAMERA_POSITION_WORLD - VERTEX;
	vec3 cam_dir_norm = normalize(cam_dir);
	float cam_dir_dist = length(cam_dir);
	
	VERTEX += camera_offset * cam_dir_norm;
	
	
}  

void fragment() {
	vec3 color = albedo.rgb;
	vec4 albedo_tex = texture(texture_albedo,UV);
	albedo_tex *= COLOR;
	
	ALBEDO = color.rgb * albedo_tex.rgb;
	ALPHA = albedo_tex.a;

}

void light() {
	// Called for every pixel for every light affecting the material.
}
