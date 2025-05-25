extends Node2D

@export var unit_scene: PackedScene
var units: Array = []
var race: String
var target: StaticBody2D = null
var finished: bool = false
var isReady = false

func launch_swarm(source_spot,target_spot):
	race = source_spot.spotOwner
	target = target_spot
	target_spot.isTarget = true
	
	var unit_count = source_spot.pop / 2
	for i in unit_count:
		source_spot.remove_unit(false)
		add_unit(source_spot.global_position)
	
func add_unit(source_pos: Vector2) -> void:
	var unit = unit_scene.instantiate()
	unit.set_race(race)
	
	# Compute direction from source to target
	var dir := (target.global_position - source_pos).normalized()

	# Compute a start position offset from source
	var offset_distance := 60 + randf_range(-5, 5)  # Tune based on Spot size
	var start_pos = source_pos + dir * offset_distance
	
	unit.position = start_pos
	unit.target = target
	units.append(unit)
	add_child(unit)
	
