extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Character"
@onready var animation_player: AnimationPlayer = $"enemy-golem-run/AnimationPlayer"

var speed: float = 2.5
var can_deal_damage: bool = true  # Hasar verebilme kontrolü
var health: int = 100  # Düşmanın canı

func _ready() -> void:
	add_to_group("enemies")  # Düşmanı "enemies" grubuna ekle
	navigation_agent.target_position = player.global_transform.origin

func reset_damage_cooldown() -> void:
	can_deal_damage = true

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()  # Can 0'a düşerse düşmanı yok et

func die():
	# EventBus üzerinden ölüm olayını yayınla
	EventBus.emit_signal("enemy_died", self)
	queue_free()  # Düşmanı sahneden kaldır

func _physics_process(_delta) -> void:
	if navigation_agent.is_navigation_finished():
		animation_player.stop()  # Hedefe ulaşıldıysa animasyonu durdur
		return  # Hedefe ulaşıldıysa hareket etmeyi durdur

	# Bir sonraki pozisyonu al
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_transform.origin).normalized()

	# Düşmanı hedefe doğru döndür
	look_at(player.global_transform.origin, Vector3.UP)

	# Düşmanı hareket ettir
	velocity = direction * speed
	move_and_slide()

	# "run" animasyonunu oynat
	if velocity.length() > 0:  # Düşman hareket ediyorsa
		if not animation_player.is_playing() or animation_player.current_animation != "mixamo_com":
			animation_player.play("mixamo_com")  # "run" animasyonunu başlat
	else:
		animation_player.stop()  # Hareket etmiyorsa animasyonu durdur

	# Çarpışma tespiti
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		
		if collider.is_in_group("player") and can_deal_damage:
			# EventBus üzerinden saldırı olayını yayınla
			EventBus.emit_signal("enemy_attacked", self, 1)  # 1 hasar ver
			can_deal_damage = false  # Hasar vermeyi geçici olarak devre dışı bırak
			# 0.5 saniye sonra hasar vermeyi yeniden etkinleştir
			get_tree().create_timer(0.5).timeout.connect(reset_damage_cooldown)

	# Hedef pozisyonunu güncelle (oyuncu hareket ederse)
	navigation_agent.target_position = player.global_transform.origin
