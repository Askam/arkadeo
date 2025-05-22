extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_race(race: String, anim: String) -> void:
	$Sheep.visible = false
	$Pig.visible = false
	$Penguin.visible = false
	
	match race :
		"sheep":
			$Sheep.visible = true
			$Sheep.animation = anim
			$Sheep.play()
		"pig":
			$Pig.visible = true
			$Pig.animation = anim
			$Pig.play()
		"penguin":
			$Penguin.visible = true
			$Penguin.animation = anim
			$Penguin.play()
