shader_type spatial;

// Baloncuk efektleri için ayarlar
uniform float fuwafuwa_speed : hint_range(0.1, 5.0) = 1.5; // Baloncuk dalgalanma hızı
uniform float fuwafuwa_size : hint_range(0.01, 0.1) = 0.05; // Baloncuk dalgalanma büyüklüğü

// Dış çizgi (outline) efektleri için ayarlar
uniform vec4 outline_color = vec4(0.45, 0.70, 1.0, 1.0); // Dış çizgi rengi
uniform float outline_ratio : hint_range(0.1, 5.0) = 1.0; // Dış çizgi yoğunluğu

// Gürültü (noise) efektleri için ayarlar
uniform float noise_speed : hint_range(0.1, 1.0) = 0.2; // Gürültü hızı
uniform float noise_scale : hint_range(0.1, 1.0) = 0.5; // Gürültü ölçeği

// HSV -> RGB dönüşümü
vec3 hsv2rgb(float h, float s, float v) {
    vec3 c = vec3(h, s, v);
    vec3 k = vec3(1.0, 2.0 / 3.0, 1.0 / 3.0);
    vec3 p = abs(fract(c.xxx + k) * 6.0 - 3.0);
    return v * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

// Rastgele sayı üretme fonksiyonu
float random(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
    // Baloncuk dalgalanma efekti
    vec3 wave = cos(VERTEX * 10.0 + vec3(TIME * fuwafuwa_speed)) + vec3(1.0);
    wave = clamp(wave, 0.0, 1.0);
    VERTEX *= 1.0 + dot(wave, wave) * fuwafuwa_size * 0.5;
}

void fragment() {
    // Dış çizgi (outline) efekti
    float outline_alpha = clamp((1.0 - dot(NORMAL, VIEW)) * outline_ratio, 0.0, 1.0);

    // Gürültü (noise) efekti
    vec3 noise_color = hsv2rgb(outline_alpha - 1.5 + noise_speed * TIME, 1.0, 1.0) * noise_scale;

    // Renk karışımı
    vec3 final_color = mix(noise_color, outline_color.rgb, max(outline_alpha - 0.3, 0.0));

    // Çıktı renk ve opaklık
    ALBEDO = final_color;
    ALPHA = outline_color.a * outline_alpha;
}