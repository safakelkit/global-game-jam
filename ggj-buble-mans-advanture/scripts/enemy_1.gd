extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Character"
@onready var animation_player: AnimationPlayer = $"enemy-demon-run/AnimationPlayer"

var speed: float = 3
var can_deal_damage: bool = true  # Controls whether the enemy can deal damage
var health: int = 10  # Enemy's health

func _ready() -> void:
	add_to_group("enemies")  # Add the enemy to the "enemies" group
	navigation_agent.target_position = player.global_transform.origin

func reset_damage_cooldown() -> void:
	can_deal_damage = true

func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()  # Destroy the enemy if health reaches 0

func die() -> void:
	queue_free()  # Remove the enemy from the scene

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		animation_player.stop()  # Stop animation if the target is reached
		return  # If the target is reached, stop moving

	# Get the next position
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_transform.origin).normalized()

	# Rotate the enemy towards the target
	look_at(player.global_transform.origin, Vector3.UP)

	# Move the enemy
	velocity = direction * speed
	move_and_slide()

	# Play "run" animation
	if velocity.length() > 0:  # If the enemy is moving
		if not animation_player.is_playing() or animation_player.current_animation != "run":
			animation_player.play("run")  # Start "run" animation
	else:
		animation_player.stop()  # Stop animation if not moving

	# Collision detection
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		
		if collider.is_in_group("player") and can_deal_damage:
			collider.take_damage()  # Deal damage to the player
			can_deal_damage = false  # Temporarily disable damage dealing
			# Re-enable damage dealing after 0.5 seconds
			get_tree().create_timer(0.5).timeout.connect(reset_damage_cooldown)

	# Update the target position (if the player moves)
	navigation_agent.target_position = player.global_transform.origin
