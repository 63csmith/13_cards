extends Node2D

const COLLISON_MASK_CARD = 1
const COLLISON_MASK_CARD_SLOT = 2
const DEFAULT_CARD_SPEED = 0.1

var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference
var filled_slots
var main_ref
var computer_hand_ref
var magnifying_glass_cursor =load("res://Assets/magnifier.png")
#really cards in slot
var cards_in_hand = []
#really cards in computers slot
var cards_in_computer_hand = []

func  _ready() -> void:
	randomize()
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	computer_hand_ref = $"../ComputerHand"
	main_ref = $".."
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y))
		
		
#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			#var card = check_for_card()
			#if card:
				#start_drag(card)
		#else:
			#if card_being_dragged: 
				#finish_drag()
			#
func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1.1, 1.1)
	card.z_index = 3
	
func finish_drag():
	card_being_dragged.scale = Vector2(1, 1)
	var card_slot_found = check_for_card_slot()
	$"../card_placed".play()
	if card_slot_found and not card_slot_found.card_in_slot:
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
		card_slot_found.card_in_the_slot = card_being_dragged
		cards_in_hand.append(card_being_dragged)
		print(cards_in_hand)
		check_all_slots_filled()
		print(filled_slots)
		add_card_to_computer_slot_based_on_player()
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_SPEED)
	card_being_dragged = null
	
# Track the status of player and computer slots
var player_slots_filled = [false, false, false]  # False = empty, True = filled
var computer_slots_filled = [false, false, false]  # False = empty, True = filled

func add_card_to_computer_slot_based_on_player():
	# Step 1: Choose a random card from the computer's hand
	var random_card_index = randi() % computer_hand_ref.computer_hand.size()
	var computer_card = computer_hand_ref.computer_hand[random_card_index]
	computer_hand_ref.computer_hand.remove_at(random_card_index)
	
	# Step 2: Find the next available player slot
	var target_slot_index = -1
	for i in range(player_slots_filled.size()):
		if player_slots_filled[i] and not computer_slots_filled[i]:
			target_slot_index = i
			break

	if target_slot_index == -1:
		print("No matching player slot to align with.")
		return

	# Step 3: Get the corresponding slot node for the computer
	var slot_node_path = "/root/Main/computer_card_slot" + str(target_slot_index + 1)
	var slot_node = get_node_or_null(slot_node_path)
	if slot_node == null:
		push_error("Slot node not found: " + slot_node_path)
		return

	# Step 4: Place the card in the corresponding slot
	computer_card.position = slot_node.position
	computer_hand_ref.update_hand_positions(0.3)

	# Step 5: Update computer slot status
	computer_slots_filled[target_slot_index] = true
	cards_in_computer_hand.append(computer_card)




func check_all_slots_filled():
	filled_slots = 0

	# Update player_slots_filled based on the card slots' status
	player_slots_filled[0] = $"../CardSlot".card_in_slot
	player_slots_filled[1] = $"../CardSlot2".card_in_slot
	player_slots_filled[2] = $"../CardSlot3".card_in_slot

	# Count filled slots
	for slot_filled in player_slots_filled:
		if slot_filled:
			filled_slots += 1

	if filled_slots == 3:
		main_ref.get_node("peek_text").text = "Time to peek"
		Input.set_custom_mouse_cursor(magnifying_glass_cursor, 0, Vector2(64, 64))



func connect_card_sig(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_left_click_released():
	if card_being_dragged: 
		finish_drag()



func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	#print("hovered")
	
	
func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		#print("hovered_off")
		var new_card_hovered = check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false



func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.1, 1.1)
		card.z_index = 2
	else :
		card.scale = Vector2(1, 1)
		card.z_index = 1


func check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISON_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISON_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null
	
	
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
			
	return highest_z_card
			
			
			
			
			
