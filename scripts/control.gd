extends Control

@onready var health_label: Label = $HealthLabel
@onready var player = $".."  # Player düğümünün üst düğüm olduğunu varsayıyoruz

var current_displayed_health: float  # Float kullanıyoruz çünkü tween ile yumuşak geçiş yapacağız

func _ready() -> void:
	if health_label == null:
		push_error("HealthLabel node'u bulunamadı!")
		return
		
	if not player:
		push_error("Player düğümü bulunamadı!")
		return

	# Player düğümünün health_changed sinyaline bağlan
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)
	else:
		push_error("Player düğümünde 'health_changed' sinyali bulunamadı!")
		return

	current_displayed_health = player.current_health
	update_health_display(player.current_health, player.MAX_HEALTH)

func _on_player_health_changed(target_health: int, maximum: int) -> void:
	# Tween oluştur
	var tween = create_tween()
	# Mevcut gösterilen candan hedef cana doğru 0.5 saniye içinde geçiş yap
	tween.tween_property(self, "current_displayed_health", target_health, 0.5)
	# Her kare güncellemesinde health label'ı güncelle
	tween.tween_callback(func(): update_health_display(target_health, maximum))

func _process(_delta: float) -> void:
	if health_label and player:
		health_label.text = "❤️ Can: %d/%d" % [round(current_displayed_health), player.MAX_HEALTH]

func update_health_display(current: int, maximum: int) -> void:
	if health_label:
		health_label.text = "❤️ Can: %d/%d" % [current, maximum]
