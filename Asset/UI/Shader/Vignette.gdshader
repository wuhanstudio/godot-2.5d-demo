shader_type canvas_item;

uniform float Intensity : hint_range(0.0, 1.0) = 0.184;
uniform vec4 Color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float Size : hint_range(0.0, 100.0) = 25.0;
uniform sampler2D ScreenTexture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment(){
	vec4 s = texture(ScreenTexture, SCREEN_UV);

	vec2 uv = UV * (1.0 - UV.xy);
	float vignette = uv.x * uv.y * Size;
	vignette = pow(vignette,Intensity);
	vignette = clamp(vignette,0.0,1.0);

	COLOR = (1.0-vignette)*Color + vignette*s;
}