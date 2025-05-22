extends Area2D

var spotOwner := "none"
var size := 0
var pop := 0
var isSelected = false
var isTarget = false
var battle = false

var wait_pop := 0
var cur_swarmed := false
var time_accumulator := 0.0

var building = "none"

@export var unit_scene: PackedScene
@export var fight_animation: PackedScene

#Défini le cooldown d'apparition d'un nouveau mouton
func get_pop_cooldown_secs() -> float:
	var c
	match size:
		0: c = 4.0
		1: c = 3.0
		2: c = 2.0
		3: c = 1.0
		_: 10.0
		
	if building == "moreSex" :
		c = c * 0.75
	return c

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wait_pop = get_pop_cooldown_secs()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PopAmount.text = str(pop)
	
	if !cur_swarmed and spotOwner != "none" and building != "plague":
		time_accumulator += delta
		if time_accumulator >= get_pop_cooldown_secs():
			if pop < 999:
				pop += 1
				add_unit()
			time_accumulator = 0.0


func add_unit() -> void:
	var unit = unit_scene.instantiate()
	unit.set_race(spotOwner,"still")
	unit.position += Vector2(randf_range(-10-5*size, 10+5*size), randf_range(-10-5*size, 10+5*size)-12)
	$UnitContainer.add_child(unit)
	
	# Apparition animée
	unit.modulate.a = 0.0
	unit.scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(unit, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(unit, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
#Permet d'initialiser le spot
func set_data(newOwner: String, newSize: int, newPop: int) -> void:
	spotOwner = newOwner
	size = clamp(newSize, 0, 3)
	pop = newPop
	update_collision_shape()
	
	#On limite le nombre d'unité a afficher dans l'enclos
	if newOwner != "none":
		var maxPop = min(pop,5+size*10)
		for n in maxPop:
			add_unit()
		
	# Masquer tous les grounds d'abord
	$GroundSheep.visible = false
	$GroundPinguin.visible = false
	$GroundPig.visible = false
	$GroundNeutral.visible = false
	
	var region = Rect2(0,100*size,100,100)
	$Shadow.texture = make_atlas($Shadow.texture.atlas, region)
	$Fence.texture = make_atlas($Fence.texture.atlas, region)
	$Selected.texture = make_atlas($Selected.texture.atlas, region)
	
	match spotOwner:
		"sheep":
			$GroundSheep.visible = true
			$GroundSheep.texture = make_atlas($GroundSheep.texture.atlas, region)
		"pig":
			$GroundPig.visible = true
			$GroundPig.texture = make_atlas($GroundPig.texture.atlas, region)
		"penguin":
			$GroundPinguin.visible = true
			$GroundPinguin.texture = make_atlas($GroundPinguin.texture.atlas, region)
		_:
			$GroundNeutral.visible = true
			$GroundNeutral.texture = make_atlas($GroundNeutral.texture.atlas, region)

func make_atlas(atlas: Texture2D, region: Rect2) -> AtlasTexture:
	var tex := AtlasTexture.new()
	tex.atlas = atlas
	tex.region = region
	return tex

func update_collision_shape():
	var shape := RectangleShape2D.new()
	var collisionPos
	match size:
		0:
			shape.size = Vector2(35, 40)
			collisionPos = Vector2(2, -17.5)
		1: 
			shape.size = Vector2(50, 56)
			collisionPos = Vector2(2, -16)
		2: 
			shape.size = Vector2(58, 64)
			collisionPos = Vector2(0, -12)
		3: 
			shape.size = Vector2(74, 81)
			collisionPos = Vector2(2, -3.5)
	$CollisionShape2D.position = collisionPos
	$CollisionShape2D.shape = shape

func set_selected(val: bool):
	$Selected.visible = val
	$Selected.modulate.a = 1
	isSelected = true

func set_target(val: bool):
	$Target.visible = val
	$Target.modulate.a = 1.0
	isSelected = true


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				get_parent().call_deferred("on_spot_click_start", self)
			else:
				get_parent().call_deferred("on_spot_click_end", self)
	pass # Replace with function body.

#Pour afficher la préselection
func _on_mouse_entered() -> void:
	if get_parent().get_parent().selected_spot == null:
		#Pas encore de selection,
		$Selected.visible = true
		$Selected.modulate.a = 0.5
	else:
		$Target.visible = true
		$Target.modulate.a = 0.5

#Pour cacher la préselection
func _on_mouse_exited() -> void:
	if !isSelected:
		$Selected.visible = false
		$Selected.modulate.a = 1
	if !isTarget:
		$Target.visible = false
		$Target.modulate.a = 1
