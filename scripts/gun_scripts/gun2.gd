extends Node3D

@export var Bullet: PackedScene

@export var muzzle_speed: float = 10
@export var millis_between_shots2: int = 0.1
@onready var rof_timer = $Timer
var can_shoot = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rof_timer.wait_time = millis_between_shots2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	if can_shoot:
		var new_bullet = Bullet.instantiate()  # Yeni mermiyi örnekle
		new_bullet.global_transform = $Muzzle.global_transform  # Mermiyi namlu pozisyonuna yerleştir
		new_bullet.speed = muzzle_speed  # Mermi hızını ayarla
		var scene_root = get_tree().current_scene  # Mevcut sahneyi al
		scene_root.add_child(new_bullet)  # Mermiyi sahneye ekle
		can_shoot = false
		rof_timer.start()

func _on_timer_timeout() -> void:
	can_shoot = true
