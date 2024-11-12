extends Node2D


signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISON_MASK_CARD = 1
const COLLISON_MASK_DECK = 4

var card_manager_ref
var deck_ref

func _ready() -> void:
	card_manager_ref = $"../CardManager"
	deck_ref = $"../Deck"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			ray_cast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")


func ray_cast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collsion_mask = result[0].collider.collision_mask
		if result_collsion_mask == COLLISON_MASK_CARD:
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager_ref.start_drag(card_found)
		elif result_collsion_mask == COLLISON_MASK_DECK:
			deck_ref.draw_card()
			
		#return result[0].collider.get_parent()
