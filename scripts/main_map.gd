extends Node3D

@export var enemy_scene: PackedScene
@export var enemy_scene2: PackedScene
@export var number_of_enemies: int = 5
@export var spawn_interval: float = 2.0

# 12 spawn noktası için export değişkenleri
@export var spawn_point1: Marker3D
@export var spawn_point2: Marker3D
@export var spawn_point3: Marker3D
@export var spawn_point4: Marker3D
@export var spawn_point5: Marker3D
@export var spawn_point6: Marker3D
@export var spawn_point7: Marker3D
@export var spawn_point8: Marker3D
@export var spawn_point9: Marker3D
@export var spawn_point10: Marker3D
@export var spawn_point11: Marker3D
@export var spawn_point12: Marker3D

# Diğer değişkenler
var spawn_points: Array[Marker3D]
var spawn_timer: Timer
var enemies_to_spawn = 0
var current_day = 1
var is_night = false
var enemy_increase_rate = 1.3

# Her spawn noktasının kullanım sayısını takip etmek için
var spawn_counts = {
	0: 0,   # spawn_point1 için sayaç
	1: 0,   # spawn_point2 için sayaç
	2: 0,   # spawn_point3 için sayaç
	3: 0,   # spawn_point4 için sayaç
	4: 0,   # spawn_point5 için sayaç
	5: 0,   # spawn_point6 için sayaç
	6: 0,   # spawn_point7 için sayaç
	7: 0,   # spawn_point8 için sayaç
	8: 0,   # spawn_point9 için sayaç
	9: 0,   # spawn_point10 için sayaç
	10: 0,  # spawn_point11 için sayaç
	11: 0,  # spawn_point12 için sayaç
}

var last_spawn_index = -1

func _ready() -> void:
	# Tüm spawn noktalarını kontrol et ve array'e ekle
	if spawn_point1 and spawn_point2 and spawn_point3 and spawn_point4 and spawn_point5 and \
	   spawn_point6 and spawn_point7 and spawn_point8 and spawn_point9 and spawn_point10 and \
	   spawn_point11 and spawn_point12:
		spawn_points = [
			spawn_point1, spawn_point2, spawn_point3, spawn_point4, spawn_point5,
			spawn_point6, spawn_point7, spawn_point8, spawn_point9, spawn_point10,
			spawn_point11, spawn_point12
		]
		setup_timer()
	else:
		push_error("Spawn noktaları atanmamış! Lütfen Inspector'dan spawn noktalarını atayın.")

	# Event Bus bağlantıları
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.enemy_attacked.connect(_on_enemy_attacked)

func setup_timer() -> void:
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(spawn_single_enemy)
	spawn_timer.one_shot = true

func start_spawning(amount: int) -> void:
	if spawn_points.is_empty():
		return

	enemies_to_spawn = amount
	spawn_single_enemy()

func get_spawn_position() -> Vector3:
	# En az kullanılan spawn noktalarından birini seç
	var min_count = spawn_counts.values().min()
	var available_indices = []

	for i in spawn_counts.keys():
		if spawn_counts[i] == min_count and i != last_spawn_index:
			available_indices.append(i)

	if available_indices.is_empty():
		available_indices = spawn_counts.keys()

	var spawn_index = available_indices.pick_random()
	last_spawn_index = spawn_index
	spawn_counts[spawn_index] += 1

	var marker = spawn_points[spawn_index]

	# Marker pozisyonu etrafında küçük bir rastgele sapma ekle
	var random_offset = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)
	)

	return marker.global_position + random_offset

func spawn_single_enemy() -> void:
	if enemies_to_spawn <= 0:
		return

	# Rastgele bir düşman sahnesi seç (enemy_scene veya enemy_scene2)
	var enemy_scene_to_spawn = [enemy_scene, enemy_scene2].pick_random()
	var enemy = enemy_scene_to_spawn.instantiate()
	add_child(enemy)
	enemy.global_position = get_spawn_position()

	# Düşmanı "enemies" grubuna ekle
	enemy.add_to_group("enemies")
	print("Spawn edilen düşman: ", enemy.name, " | Grup üyeliği: ", enemy.is_in_group("enemies"))

	# Event Bus üzerinden spawn olayını yayınla
	EventBus.emit_signal("enemy_spawned", enemy)

	enemies_to_spawn -= 1
	print("Kalan spawn edilecek düşman: ", enemies_to_spawn)

	if enemies_to_spawn > 0:
		spawn_timer.start()

func _on_enemy_died(enemy):
	print("Düşman yok edildi: ", enemy.name)
	
	# Debug bilgileri
	var remaining_enemies = get_tree().get_nodes_in_group("enemies").size()
	print("Kalan düşman sayısı: ", remaining_enemies)
	print("Spawn bekleyen: ", enemies_to_spawn)
	print("Gece aktif mi: ", is_night)
	
	if is_night and enemies_to_spawn <= 0 and remaining_enemies == 1:
		print("═════════════════════════════════")
		print("Tüm düşmanlar temizlendi!")
		print("═════════════════════════════════")
		end_night()

func _on_enemy_attacked(enemy, damage):
	print("Saldırıya uğrayan düşman: ", enemy.name)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next-night"):
		start_night()

func start_night() -> void:
	if is_night:
		print("Gece zaten devam ediyor!")
		return

	print("\n===================================")
	print("🌙 Gece ", current_day, " başladı! Düşman sayısı: ", number_of_enemies)
	print("===================================")
	
	is_night = true
	EventBus.emit_signal("night_started")
	start_spawning(number_of_enemies)

func end_night() -> void:
	print("\n===================================")
	print("☀️ Gece ", current_day, " tamamlandı!")
	print("===================================")
	
	is_night = false
	current_day += 1
	number_of_enemies = int(number_of_enemies * enemy_increase_rate)
	EventBus.emit_signal("night_ended", current_day)
