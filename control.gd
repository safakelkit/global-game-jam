extends Node2D  # or CanvasLayer, depending on your root node

# Array to hold the image paths
var images = [
	"res://story/1.replik.jpg",
	"res://story/2.replik.jpg",
	"res://story/3.replik.png",
	"res://story/4.replik.png"
]

# Index to track the current image
var current_image_index = 0

# Reference to the Sprite2D node
@onready var sprite = $Sprite2D

# Reference to the Timer node
@onready var timer = $Timer

func _ready():
	# Timer sinyalini bağla
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	# Start the cutscene by displaying the first image
	show_next_image()

func show_next_image():
	if current_image_index < images.size():
		# Update the sprite's texture
		sprite.texture = load(images[current_image_index])
		# Start the timer
		timer.start()
		# Increment the index for the next image
		current_image_index += 1
	else:
		# End the cutscene and transition to the main game
		end_cutscene()

func _on_timer_timeout():
	# When the timer ends, show the next image
	show_next_image()

func end_cutscene():
	# Transition to the main game scene
	get_tree().change_scene_to_file("res://main-map.tscn")  # Replace with your main game scene path
