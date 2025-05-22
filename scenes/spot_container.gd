extends Node2D


@export var spot_scene: PackedScene
@export var num_spots: int = 12
@export var area_size := Vector2(1024, 640)
@export var area_offset := Vector2(0, 80)
@export var min_distance := 100.0
@export var num_players: int = 2
@export var difficulty := 0

var rng := RandomNumberGenerator.new()
var races := ["penguin", "sheep", "pig"]
var active_races := []
var spots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_spots()
	rng.randomize()	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
#Génération du terrain
func spawn_spots():
	var tries = 0
	var target_size = rng.randi_range(0, 3)
	spots.clear()

	var player_spots := num_players
	var ai_spots := 0
	active_races.clear()

	# Détermine les races des joueurs
	if num_players == 1:
		active_races.append("sheep")   # Joueur 1
		active_races.append("penguin") # IA
		ai_spots = 1 + difficulty
	else:
		for i in range(num_players):
			active_races.append(races[i])

	var total_players := active_races.size()

	# Étape 1 : générer plein de positions valides
	var candidate_positions: Array[Vector2] = []
	while candidate_positions.size() < num_spots * 4 and tries < 1000:
		var pos = Vector2(
			rng.randf_range(80, area_size.x - 80),
			rng.randf_range(80, area_size.y - 80)
		) + area_offset

		if is_far_enough_from_list(pos, candidate_positions, min_distance):
			candidate_positions.append(pos)
		tries += 1

	# Étape 2 : choisir les positions les plus éloignées pour les joueurs
	var player_positions: Array[Vector2] = []
	if candidate_positions.size() >= total_players:
		# Méthode simple : choisir le 1er au hasard, puis toujours le plus éloigné du précédent
		player_positions.append(candidate_positions.pop_front())
		while player_positions.size() < total_players:
			var best_pos
			var best_dist := -1.0
			for pos in candidate_positions:
				var total_dist = 0.0
				for p in player_positions:
					total_dist += pos.distance_to(p)
				if total_dist > best_dist:
					best_dist = total_dist
					best_pos = pos
			player_positions.append(best_pos)
			candidate_positions.erase(best_pos)

	# Étape 3 : instancier les spots joueurs (ou IA)
	for i in range(total_players):
		var spot = spot_scene.instantiate()
		spot.position = player_positions[i]
		spot.set_data(active_races[i], target_size, 30)
		add_child(spot)
		spots.append(spot)

	# Étape 4 : ajouter des spots IA supplémentaires si besoin
	for i in range(ai_spots - 1):  # -1 car IA a déjà 1 spot en position joueur
		if candidate_positions.is_empty():
			break
		var pos = candidate_positions.pop_front()
		var spot = spot_scene.instantiate()
		spot.position = pos
		spot.set_data("penguin", rng.randi_range(0, 3), 30)
		add_child(spot)
		spots.append(spot)

	# Étape 5 : spots neutres
	while spots.size() < num_spots and candidate_positions.size() > 0:
		var pos = candidate_positions.pop_front()
		var spot = spot_scene.instantiate()
		spot.position = pos
		var spot_size = rng.randi_range(0, 3)
		spot.set_data("none", spot_size, rng.randi_range(0, 10+spot_size*10))
		add_child(spot)
		spots.append(spot)
		
		
func is_far_enough(pos: Vector2) -> bool:
	for s in spots:
		if s.position.distance_to(pos) < min_distance:
			return false
	return true
	
func is_far_enough_from_list(pos: Vector2, others: Array, min_dist: float) -> bool:
	for o in others:
		if pos.distance_to(o) < min_dist:
			return false
	return true


func randi_range(min_val: int, max_val: int) -> int:
	return rng.randi_range(min_val, max_val)
