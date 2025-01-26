extends Sprite2D

func _ready():
	# Ekran boyutunu al
	var screen_size = get_viewport_rect().size
	
	# Görselin boyutunu ekran boyutuna göre ayarla
	self.scale = Vector2(screen_size.x / self.texture.get_width(), screen_size.y / self.texture.get_height())
