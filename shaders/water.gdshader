shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(-0.05, -0.05);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform float distortion_strength: hint_range(-1,1) = 0.2;
uniform vec4 tone_color: source_color;
uniform float alpha_total : hint_range(0.0, 1.0) = 1.0;
uniform vec4 top_color: source_color;
uniform float light_start: hint_range(0.0, 1.0) = 0.275;
uniform float light_end: hint_range(0.0, 1.0) = 0.4;
uniform float screen_offset_x : hint_range(-1.0, 1.0) = 0.0;
uniform float screen_offset_y: hint_range(-1.0, 1.0) = 0.0;
uniform float wave_speed = 3.0;
uniform float wave_freq = 10.0;
uniform float wave_width = 1.0;

uniform float wave_count = 10.0; // Quantidade de ondas
uniform float wave_bias = 0.001;

void vertex() {
	VERTEX.y += sin(TIME * wave_speed + VERTEX.x * wave_freq) * wave_width;
}

void fragment() {
    // 1. Cálculo das ondas laterais
    float x_offset = sin(UV.y * wave_count + TIME * wave_speed) * wave_bias;
    
    // 2. UVs do ruído (mantendo sua lógica)
    vec2 distorted_uv = UV + vec2(x_offset, 0.0);
    
    // 3. Leitura dos ruídos
    float depth = texture(noise, distorted_uv + scroll * TIME).r * texture(noise2, distorted_uv + scroll2 * TIME).r;
    
    // 4. DISTORÇÃO DA TELA COM ALINHAMENTO X e Y
    // Adicionamos os offsets para corrigir o posicionamento do que está "atrás" da água
    vec2 screen_dist = (distortion_strength * vec2(depth)) + vec2(x_offset + screen_offset_x, screen_offset_y);
    
    // Uso do clamp para segurança no topo da tela (resolvido anteriormente)
    vec2 final_uv = clamp(SCREEN_UV + screen_dist, vec2(0.001), vec2(0.999));
    vec4 screen_col = texture(SCREEN_TEXTURE, final_uv);
    
    // 5. Brilho da espuma
    vec4 top_light = smoothstep(light_start, light_end, depth) * top_color;
    
    // 6. Resultado Final
    COLOR = screen_col * tone_color + top_light;
    COLOR.a = alpha_total;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
