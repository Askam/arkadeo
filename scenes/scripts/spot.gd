extends StaticBody2D

var spotOwner := "none"
var size := 0
var pop := 0
var isSelected = false
var isTarget = false
var battle = false

var cur_swarmed := false
var time_accumulator := 0.0
var maxVisiblePop
var units = []

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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PopAmount.text = str(pop)
	
	if !cur_swarmed and spotOwner != "none" and building != "plague":
		time_accumulator += delta
		if time_accumulator >= get_pop_cooldown_secs():
			if pop < 50 + size*50:
				pop += 1
				#On affiche pas le nouveau mouton si y a plus la place
				if pop <= maxVisiblePop:
					add_unit()
			time_accumulator = 0.0

#Ajoute 1 unitée
func add_unit() -> void:
	var unit = unit_scene.instantiate()
	unit.set_race(spotOwner)
	unit.position += Vector2(randf_range(-10-5*size, 10+5*size), randf_range(-10-5*size, 10+5*size)-12)
	$UnitContainer.add_child(unit)
	units.append(unit)
	
	# Apparition animée
	unit.modulate.a = 0.0
	unit.scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(unit, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(unit, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
func remove_unit(isKill: bool) -> void:
	pop = max(pop - 1, 0)

	# Supprimer une unité visible uniquement si on est sous la limite d'affichage
	if pop <= maxVisiblePop:
		var unit_container := $UnitContainer
		if unit_container.get_child_count() > 0:
			var unit = unit_container.get_child(unit_container.get_child_count() - 1)

			if isKill and unit.has_method("kill"):
				unit.kill()
			else:
				unit.queue_free()
	
#Permet d'initialiser le spot
func set_data(newOwner: String, newSize: int, newPop: int) -> void:
	size = clamp(newSize, 0, 3)
	change_owner(newOwner)
	pop = newPop
	maxVisiblePop = 5+size*15
	update_collision_shape()
	
	#On limite le nombre d'unité a afficher dans l'enclos
	if newOwner != "none":
		var maxPop = min(pop,maxVisiblePop)
		for n in maxPop:
			add_unit()
		
	var region = Rect2(0,100*size,100,100)
	$Shadow.texture = make_atlas($Shadow.texture.atlas, region)
	$Fence.texture = make_atlas($Fence.texture.atlas, region)
	$Selected.texture = make_atlas($Selected.texture.atlas, region)
	$Target.texture = make_atlas($Target.texture.atlas, region)

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
	$MouseDetectionArea.get_node("CollisionShape2D").shape = RectangleShape2D.new()
	$MouseDetectionArea.get_node("CollisionShape2D").position = collisionPos
	$MouseDetectionArea.get_node("CollisionShape2D").shape.size = shape.size + Vector2(5,5)

func set_selected(val: bool):
	$Selected.visible = val
	$Selected.modulate.a = 1
	isTarget = true

func set_target(val: bool):
	$Target.visible = val
	$Target.modulate.a = 1.0
	isTarget = true


#Détecter les clics
func _on_mouse_detection_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				get_parent().get_parent().call_deferred("on_spot_click_start", self)
			else:
				get_parent().get_parent().call_deferred("on_spot_click_end", self)
	pass # Replace with function body.

#Pour afficher la préselection
func _on_mouse_detection_area_mouse_entered() -> void:
	if get_parent().get_parent().selected_spot == null:
		#Pas encore de selection,
		$Selected.visible = true
		$Selected.modulate.a = 0.5
	else:
		$Target.visible = true
		$Target.modulate.a = 0.5

#Pour cacher la préselection
func _on_mouse_detection_area_mouse_exited() -> void:
	if !isSelected:
		$Selected.visible = false
		$Selected.modulate.a = 1
	if !isTarget:
		$Target.visible = false
		$Target.modulate.a = 1

#On utilise l'area de la souris pour détecter les moutons
func _on_mouse_detection_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("unit"):
		if body.target == self:
			var unit_race = body.race
			if unit_race == spotOwner:
				body.queue_free() 
				pop += 1
				if pop < maxVisiblePop:
					add_unit()
			else:
				remove_unit(true)
				body.queue_free()  # Placeholder pour combat
				if pop <= 0:
					change_owner(body.race)
					
func change_owner(new_owner):
	spotOwner = new_owner
	
		# Masquer tous les grounds d'abord
	$GroundSheep.visible = false
	$GroundPinguin.visible = false
	$GroundPig.visible = false
	$GroundNeutral.visible = false
	
	var region = Rect2(0,100*size,100,100)
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
