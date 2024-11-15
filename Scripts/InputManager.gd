extends Node2D


signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISON_MASK_CARD = 1
const COLLISON_MASK_DECK = 4
const COLLISON_MASK_SLOT = 2

var main_ref
var card_manager_ref
var deck_ref
var computer_hand_ref
var can_peek = true
var trade_slot
var trade_card




func _ready() -> void:
	main_ref = $".."
	card_manager_ref = $"../CardManager"
	deck_ref = $"../Deck"
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false
	




func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			deck_ref.get_node("Deck_warning").text = ""
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
		elif result_collsion_mask == COLLISON_MASK_SLOT:
			var slot_found = result[0].collider.get_parent()
			var slot_card = slot_found.card_in_slot
			var slots_filled = card_manager_ref.filled_slots
			#print(slot_found)
			if slot_card and slots_filled == 3 and can_peek:
				$"../card_flip".play()
				#print(slot_found.card_in_the_slot)
				slot_found.card_in_the_slot.scale = Vector2(1.01, 1.01)
				#slot_found.card_in_the_slot.get_node("card_name").visible = true
				trade_slot = slot_found
				trade_card = slot_found.card_in_the_slot
				can_peek = false
				trade_card.get_node("AnimationPlayer").play("card_flip")
				$Trade.disabled = false
				$Trade.visible = true
				$Keep.disabled = false
				$Keep.visible = true
				Input.set_custom_mouse_cursor(null)
		elif result_collsion_mask == COLLISON_MASK_DECK:
			deck_ref.get_node("Deck_warning").text = "Opps cant draw yet"
			#deck_ref.draw_card()
			
		#return result[0].collider.get_parent()
func _on_trade_pressed():
	deck_ref.replace_card(trade_slot)
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false
	main_ref.get_node("peek_text").text = ""
	#flip card 1,2, and 3
	$"../card_flip".play()
	card_manager_ref.cards_in_hand[0].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_hand[1].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_hand[2].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_computer_hand[2].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_computer_hand[1].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_computer_hand[0].get_node("AnimationPlayer").play("card_flip")	



func _on_keep_pressed():
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false
	main_ref.get_node("peek_text").text = ""
	#flip card 1,2, and 3
	$"../card_flip".play()
	card_manager_ref.cards_in_hand[0].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_hand[1].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_hand[2].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_computer_hand[2].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_computer_hand[1].get_node("AnimationPlayer").play("card_flip")
	card_manager_ref.cards_in_computer_hand[0].get_node("AnimationPlayer").play("card_flip")

