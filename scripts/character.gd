extends CharacterBody3D

signal health_changed(target_health: int, maximum: int)

@onready var gun_controller = $GunController
@onready var animation_player: AnimationPlayer = $body/AnimationPlayer
@onready var body: Node3D = get_node("body")

## Laserbeam height
@export var beam_height_offset: float = 1.2

const speed = 5
const MAX_HEALTH = 100  # Maksimum can değeri
const DAMAGE_AMOUNT = 20  # Her vuruşta gidecek can miktarı
const DAMAGE_COOLDOWN = 0.5  # Hasar arası bekleme süresi

var is_alive: bool = true
var current_health: int = MAX_HEALTH
var has_printed_initial_health: bool = false
var can_take_damage: bool = true  # Hasar alabilme kontrolü

func _ready() -> void:
	add_to_group("player")
	reset_health()
	if not has_printed_initial_health:
		print_health_status()
		has_printed_initial_health = true

func reset_health() -> void:
	current_health = MAX_HEALTH
	is_alive = true
	health_changed.emit(current_health, MAX_HEALTH)  # Canı sıfırla ve sinyal gönder

func print_health_status() -> void:
	print("Can: ", current_health, "/", MAX_HEALTH)

func take_damage() -> void:
	if not is_alive:
		return
	
	current_health -= DAMAGE_AMOUNT
	health_changed.emit(current_health, MAX_HEALTH)  # Can değişikliğini sinyal ile bildir
	print("Hasar aldın! Can: ", current_health, "/", MAX_HEALTH)
	
	if current_health <= 0:
		die()

func die() -> void:
	is_alive = false
	current_health = 0
	health_changed.emit(current_health, MAX_HEALTH)  # Can değişikliğini sinyal ile bildir
	print("Öldün! Can: ", current_health, "/", MAX_HEALTH)
	
	# Ölüm animasyonunu oynat (eğer varsa)
	if animation_player.has_animation("death"):
		animation_player.play("death")
	
	# Sahneyi güvenli bir şekilde yeniden yükle
	var scene_tree = get_tree()
	if scene_tree != null:
		var current_scene = scene_tree.current_scene
		if current_scene != null:
			var timer = scene_tree.create_timer(2.0)
			timer.timeout.connect(func():
				if scene_tree != null and scene_tree.current_scene != null:
					var err = scene_tree.reload_current_scene()
					if err != OK:
						print("Sahne yeniden yüklenemedi: ", err)
			)

func _unhandled_input(event: InputEvent) -> void:
	if not is_alive:
		return
	if event is InputEventMouseMotion:
		var cursor = get_viewport().get_mouse_position()
		_project_cursor(cursor, beam_height_offset)

func _project_cursor(cursor_position: Vector2, beam_height: float) -> void:
	if not is_alive:
		return
		
	var aim_plane = Plane.PLANE_XZ
	aim_plane.d = beam_height

	var camera: Camera3D = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(cursor_position)
	var ray_direction = camera.project_ray_normal(cursor_position)

	var intersection: Variant = aim_plane.intersects_ray(ray_origin, ray_direction)
	if intersection is not Vector3:
		push_error("Intersection with plane not found")
		return

	var aim_point: Vector3 = intersection
	var direction = aim_point - body.global_position
	var angle = atan2(direction.x, direction.z)
	body.rotation.y = angle

func _process(_delta) -> void:
	if not is_alive:
		return
		
	velocity = Vector3()

	# İleri hareket (W tuşu)
	if Input.is_action_pressed("ui_up"):  # "ui_up" tuşuna basıldığında
		# Karakterin yönüne doğru hareket et
		velocity.x = sin(body.rotation.y) * speed
		velocity.z = cos(body.rotation.y) * speed

	# Geri gitme (S tuşu)
	if Input.is_action_pressed("ui_down"):  # "ui_down" tuşuna basıldığında
		# Karakterin ters yönüne doğru hareket et
		velocity.x = -sin(body.rotation.y) * speed
		velocity.z = -cos(body.rotation.y) * speed

	# Yürüme animasyonunu kontrol et
	if velocity.length() > 0:  # Eğer karakter hareket ediyorsa
		if not animation_player.is_playing() or animation_player.current_animation != "walk":
			animation_player.play("walk")  # "walk" animasyonunu oynat
		# Animasyon hızını karakterin hızına göre ayarla
		animation_player.speed_scale = velocity.length() / speed * 2.0  # 2 kat hızlandır
	else:  # Eğer karakter hareket etmiyorsa
		if animation_player.is_playing() and animation_player.current_animation == "walk":
			animation_player.stop()  # Yürüme animasyonunu durdur
		animation_player.play("idle")  # "idle1" animasyonunu oynat

	move_and_slide()
	
	# Silah kontrolü
	if Input.is_action_pressed("primary_action"):
		gun_controller.shoot()
	
	if Input.is_action_just_pressed("change_weapon"):
		gun_controller.change_weapon()

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Çarpışma kontrolü
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("enemies") && can_take_damage:
			take_damage()
			can_take_damage = false
			# Cooldown timer'ı başlat
			get_tree().create_timer(DAMAGE_COOLDOWN).timeout.connect(_reset_damage_cooldown)

func _reset_damage_cooldown():
	can_take_damage = true
