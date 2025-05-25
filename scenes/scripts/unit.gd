extends CharacterBody2D

var target : StaticBody2D
var speed: float = 60.0
var avoid_force := Vector2.ZERO
var race: String
var active_sprite: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("unit")
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		update_animation(direction)
		# Déplacement avec gestion de collisions physiques
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_reach_target() -> void:
	if target is StaticBody2D and target.has_method("spotOwner"):
		var target_race = target.spotOwner
		if target_race != race:
			print("⚔ Combat déclenché !") # 🔁 Placeholder combat
		else:
			print("🤝 Transfert d'unités") # 🔁 Placeholder transfert
	else:
		print("🎯 Cible atteinte mais non reconnue")

	queue_free() # L'unité disparaît après l'action

func set_race(newRace: String) -> void:
	$Sheep.visible = false
	$Pig.visible = false
	$Penguin.visible = false
	race = newRace
	
	match race :
		"sheep":
			active_sprite = $Sheep
		"pig":
			active_sprite = $Pig
		"penguin":
			active_sprite = $Penguin
	
	active_sprite.visible = true
	active_sprite.animation = "still"
	active_sprite.play()
	
func update_animation(direction: Vector2) -> void:
	if not active_sprite:
		return

	if direction == Vector2.ZERO:
		active_sprite.animation = "still"
		active_sprite.flip_h = false
	else:
		# Horizontal movement takes priority if it's stronger
		if abs(direction.x) > abs(direction.y):
			active_sprite.animation = "right"
			active_sprite.flip_h = direction.x < 0
		elif direction.y > 0:
			active_sprite.animation = "down"
			active_sprite.flip_h = false
		else:
			active_sprite.animation = "up"
			active_sprite.flip_h = false

	active_sprite.play()

func kill() -> void:
	if not active_sprite:
		queue_free()
		return

	active_sprite.animation = "splash"
	active_sprite.play()
	await get_tree().create_timer(1).timeout
	queue_free()
