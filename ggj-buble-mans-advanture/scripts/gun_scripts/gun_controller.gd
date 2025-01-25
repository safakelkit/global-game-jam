extends Node

@export var StartingWeapon: PackedScene
@onready var weapon_changing_timer = $Timer
@export var weapon_scenes: Array[String] = [
	"res://objects/gun_mechanics/gun.tscn",
	"res://objects/gun_mechanics/gun_2.tscn",
	"res://objects/gun_mechanics/gun_3.tscn"
]  # İstediğiniz kadar sahne yolu ekleyebilirsiniz.
var hand: Marker3D
var equipped_weapon: Node3D
var current_weapon_index: int = 0  # Aktif silahın indeksini takip eder.
var can_change_weapon: bool = true  # Silah değiştirme izni

func _ready():
	hand = $"../body/Hand"  # "Hand" düğümünü bul
	weapon_changing_timer.wait_time = 0.3  # 5 saniye bekleme süresi
	
	# Başlangıç silahını yükle
	if StartingWeapon:
		equip_weapon(StartingWeapon)
	
	# Timer'ın timeout sinyalini bağla
	weapon_changing_timer.timeout.connect(_on_timer_timeout)

func equip_weapon(weapon_to_equip: PackedScene):
	if equipped_weapon:
		equipped_weapon.queue_free()  # Önceki silahı kaldır
	else:
		print("No weapon equipped")
		
	equipped_weapon = weapon_to_equip.instantiate()  # Yeni silahı örnekle
	hand.add_child(equipped_weapon)  # Silahı "Hand" düğümüne ekle

func shoot():
	if equipped_weapon and equipped_weapon.has_method("shoot"):
		equipped_weapon.shoot()

func change_weapon():
	if not can_change_weapon:
		print("Weapon change on cooldown. Please wait.")
		return  # Silah değiştirme izni yoksa çık
	
	# Sıradaki silahı seçmek için indeks artır
	current_weapon_index = (current_weapon_index + 1) % weapon_scenes.size()
	var next_weapon_scene_path = weapon_scenes[current_weapon_index]
	
	var new_weapon_scene = load(next_weapon_scene_path)
	if new_weapon_scene is PackedScene:
		equip_weapon(new_weapon_scene)
		print("Equipped weapon scene:", next_weapon_scene_path)
	else:
		print("Failed to load weapon scene:", next_weapon_scene_path)
	
	# Silah değiştirme iznini kapat ve zamanlayıcıyı başlat
	can_change_weapon = false
	weapon_changing_timer.start()

func _on_timer_timeout():
	# Zamanlayıcı dolduğunda silah değiştirme iznini ver
	can_change_weapon = true
	print("Weapon change cooldown over. You can change weapons now.")
