extends Node3D

@export var Bullet: PackedScene
@export var muzzle_speed: float = 10
@export var millis_between_shots1: float = 2

@onready var rof_timer = $Timer

var can_shoot = true

func _ready() -> void:
	rof_timer.wait_time = millis_between_shots1

func shoot():
	if can_shoot and Bullet:
		var new_bullet = Bullet.instantiate()
		var new_bullet2 = Bullet.instantiate()  # Yeni mermiyi örnekle
		new_bullet.global_transform = $Muzzle.global_transform  # Mermiyi namlu pozisyonuna yerleştir
		new_bullet2.global_transform = $Muzzle2.global_transform 
		
		# Mermi hızını ayarla (eğer speed özelliği varsa)
		if new_bullet.has_method("set_speed") and new_bullet.has_method("set_speed"):
			new_bullet.speed = muzzle_speed
			new_bullet2.speed = muzzle_speed
		
		var scene_root = get_tree().current_scene  # Mevcut sahneyi al
		scene_root.add_child(new_bullet)  # Mermiyi sahneye ekle
		scene_root.add_child(new_bullet2)
		can_shoot = false
		rof_timer.start()

func _on_timer_timeout() -> void:
	can_shoot = true
