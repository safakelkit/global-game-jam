extends Control

# TextureRect'ları tanımla
@onready var top_left = $TopLeft
@onready var top_right = $TopRight
@onready var bot_left = $BottomLeft
@onready var bot_right = $BottomRight

# Animasyon ayarları
var current_step = 0
var is_auto_playing = true
var animation_speed = 0.8
var wait_time = 1.2

# Sıralı gösterim için dizi
var parts_sequence = []

func _ready():
	# Parçaları sıralı diziye ekle
	parts_sequence = [top_left, top_right, bot_left, bot_right]
	
	# Başlangıç ayarları
	initialize_parts()
	adjust_texture_rects()
	
	if is_auto_playing:
		start_animation_sequence()

func initialize_parts():
	# Tüm parçaları başlangıçta gizle
	for part in parts_sequence:
		part.modulate = Color.TRANSPARENT
		part.scale = Vector2(0.9, 0.9)

func adjust_texture_rects():
	var screen_size = get_viewport_rect().size
	
	# Her parçayı sırayla yerleştir
	top_left.size = screen_size / Vector2(2, 2)
	top_left.position = Vector2(0, 0)
	
	top_right.size = screen_size / Vector2(2, 2)
	top_right.position = Vector2(screen_size.x / 2, 0)
	
	bot_left.size = screen_size / Vector2(2, 2)
	bot_left.position = Vector2(0, screen_size.y / 2)
	
	bot_right.size = screen_size / Vector2(2, 2)
	bot_right.position = Vector2(screen_size.x / 2, screen_size.y / 2)

func start_animation_sequence():
	# Her parçayı sırayla göster
	for part in parts_sequence:
		animate_part_fade_in(part)
		await get_tree().create_timer(wait_time).timeout

func animate_part_fade_in(part):
	var tween = create_tween()
	
	# Fade ve scale animasyonu
	tween.set_parallel(true)
	tween.tween_property(part, "modulate", Color.WHITE, animation_speed)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(part, "scale", Vector2(1.0, 1.0), animation_speed * 0.6)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _input(event):
	# Tıklamayla manuel kontrol
	if event is InputEventMouseButton and event.pressed:
		if current_step < parts_sequence.size():
			animate_part_fade_in(parts_sequence[current_step])
			current_step += 1
		else:
			current_step = 0  # Döngüyü başa sar

func reset_animation():
	current_step = 0
	initialize_parts()
	if is_auto_playing:
		start_animation_sequence()

func _on_resized():
	adjust_texture_rects()
