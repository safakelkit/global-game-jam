extends Node3D

@export var enemy_scene: PackedScene
@export var number_of_enemies: int = 5
@export var spawn_interval: float = 2.0

# 13 spawn noktası için export değişkenleri
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

var spawn_points: Array[Marker3D]
var spawn_timer: Timer
var enemies_to_spawn = 0

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
	   spawn_point11 and spawn_point12 :
		spawn_points = [
			spawn_point1, spawn_point2, spawn_point3, spawn_point4, spawn_point5,
			spawn_point6, spawn_point7, spawn_point8, spawn_point9, spawn_point10,
			spawn_point11, spawn_point12
		]
		setup_timer()
		start_spawning(number_of_enemies)
	else:
		push_error("Spawn noktaları atanmamış! Lütfen Inspector'dan spawn noktalarını atayın.")

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
	var min_count = 999999
	var available_indices = []
	
	# En az kullanılan sayıyı bul
	for i in spawn_counts.keys():
		if spawn_counts[i] < min_count:
			min_count = spawn_counts[i]
	
	# En az kullanılan spawn noktalarını topla
	for i in spawn_counts.keys():
		if spawn_counts[i] == min_count and i != last_spawn_index:
			available_indices.append(i)
	
	# Rastgele bir spawn noktası seç
	var spawn_index = available_indices.pick_random()
	last_spawn_index = spawn_index
	spawn_counts[spawn_index] += 1
	
	var marker = spawn_points[spawn_index]
	
	# Debug: Spawn noktalarının kullanım sayılarını yazdır
	print("Spawn kullanım sayıları: ", spawn_counts)
	
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
		
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = get_spawn_position()
	
	enemies_to_spawn -= 1
	
	if enemies_to_spawn > 0:
		spawn_timer.start()
