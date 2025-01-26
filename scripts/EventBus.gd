# EventBus.gd
extends Node

# Düşmanla ilgili olaylar
signal enemy_spawned(enemy)  # Düşman spawn olduğunda
signal enemy_died(enemy)     # Düşman öldüğünde
signal enemy_attacked(enemy, damage)  # Düşman saldırdığında

# Gece-gündüz döngüsü ile ilgili olaylar
signal night_started         # Gece başladığında
signal night_ended           # Gece bittiğinde

# Singleton örneği
static var instance: EventBus

func _ready():
	instance = self
