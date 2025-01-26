extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Character"
@onready var animation_player: AnimationPlayer = $"enemy-demon-run/AnimationPlayer"

# Configuration
@export var speed: float = 2.5
@export var health: int = 50
@export var attack_damage: int = 1
@export var attack_interval: float = 0.5

# State variables
var can_attack: bool = true
var player_in_attack_range: bool = false
var attack_cooldown_timer: Timer

func _ready() -> void:
	# Initialize nodes
	add_to_group("enemies")
	navigation_agent.target_position = player.global_position
	
	# Set up collision layers (player layer = 1)
	collision_mask &= ~(1 << 0)
	
	# Create and configure attack timer
	attack_cooldown_timer = Timer.new()
	add_child(attack_cooldown_timer)
	attack_cooldown_timer.wait_time = attack_interval
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	
	# Initialize navigation
	navigation_agent.target_desired_distance = 0.1
	navigation_agent.path_desired_distance = 0.1

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		animation_player.stop()
		return

	# Update navigation target
	navigation_agent.target_position = player.global_position
	
	# Calculate movement direction
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	# Smooth rotation using quaternion slerp
	var target_direction = (player.global_position - global_position).normalized()
	var target_basis = Basis.looking_at(target_direction, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(target_basis, delta * 4)

	# Apply movement
	velocity = direction * speed
	move_and_slide()

	# Animation control
	if velocity.length() > 0.1:
		if not animation_player.is_playing() or animation_player.current_animation != "run":
			animation_player.play("run")
	else:
		animation_player.stop()

	# Attack logic
	if player_in_attack_range and can_attack:
		attack_player()

func attack_player():
	EventBus.emit_signal("enemy_attacked", self, attack_damage)
	can_attack = false
	attack_cooldown_timer.start()

func _on_attack_cooldown_timeout():
	can_attack = true

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func die():
	EventBus.emit_signal("enemy_died", self)
	queue_free()

# Area3D signal handlers
func _on_attack_range_body_entered(body: Node):
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_attack_range_body_exited(body: Node):
	if body.is_in_group("player"):
		player_in_attack_range = false
