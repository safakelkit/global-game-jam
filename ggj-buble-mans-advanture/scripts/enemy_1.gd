extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Character"
@onready var animation_player: AnimationPlayer = $"enemy-demon-run/AnimationPlayer"  # AnimationPlayer düğümünü ekleyin

var speed: float = 3
var can_deal_damage: bool = true  # Hasar verip veremeyeceğini kontrol eden değişken

func _ready() -> void:
	# Hedef pozisyonunu ayarla (örneğin, oyuncunun pozisyonu)
	navigation_agent.target_position = player.global_transform.origin

func reset_damage_cooldown() -> void:
	can_deal_damage = true

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		animation_player.stop()  # Hedefe ulaşıldığında animasyonu durdur
		return  # Eğer hedefe ulaşıldıysa hareket etme

	# Bir sonraki pozisyonu al
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_transform.origin).normalized()

	# Karakterin yönünü hedefe doğru döndür
	look_at(player.global_transform.origin, Vector3.UP)

	# Hareket et
	velocity = direction * speed
	move_and_slide()

	# "Run" animasyonunu oynat
	if velocity.length() > 0:  # Eğer karakter hareket ediyorsa
		if not animation_player.is_playing() or animation_player.current_animation != "run":
			animation_player.play("run")  # "Run" animasyonunu başlat
	else:
		animation_player.stop()  # Hareket etmiyorsa animasyonu durduwr

	# Çarpışma kontrolü
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		
		if collider.is_in_group("player") and can_deal_damage:
			collider.take_damage()  # Hasar ver
			can_deal_damage = false  # Hasar vermeyi geçici olarak devre dışı bırak
			# 0.5 saniye sonra tekrar hasar verebilir
			get_tree().create_timer(0.5).timeout.connect(reset_damage_cooldown)

	# Hedef pozisyonunu güncelle (oyuncu hareket ediyorsa)
	navigation_agent.target_position = player.global_transform.origin
