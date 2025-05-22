extends Node2D

var selected_spot: Area2D = null
var is_dragging := false
var current_hover: Area2D = null
var drag_line: Line2D = null

func _ready():
	pass
	
func _process(_delta):
	if is_dragging and selected_spot != null:
		var mouse_pos = get_viewport().get_mouse_position()
		drag_line.set_point_position(1, mouse_pos)

		
func create_drag_line():
	drag_line = Line2D.new()
	drag_line.default_color = Color.WHITE
	drag_line.width = 2
	drag_line.add_point(selected_spot.global_position)
	drag_line.add_point(selected_spot.global_position)
	add_child(drag_line)		

func update_hover_target(mouse_pos: Vector2):
	current_hover = null
	for spot in $SpotContainer.spots:
		if spot.get_global_rect().has_point(mouse_pos) and spot != selected_spot:
			current_hover = spot
			spot.set_target(true)
		else:
			spot.set_target(false)
		

func on_spot_click_start(spot) -> void:
	if spot.spotOwner == "sheep":  # ou ton joueur courant
		selected_spot = spot
		selected_spot.set_selected(true)
		is_dragging = true
		create_drag_line()

func on_spot_click_end(spot) -> void:
	if is_dragging and selected_spot != null and spot != selected_spot:
		print("Swarm from %s to %s" % [selected_spot.name, spot.name])  # Placeholder
	selected_spot.set_selected(false)
	
