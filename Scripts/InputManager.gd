extends Node2D


signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISON_MASK_CARD = 1
const COLLISON_MASK_DECK = 4
const COLLISON_MASK_SLOT = 2


var main_ref
var card_manager_ref
var deck_ref
var player_hand_ref
var computer_hand_ref
var can_peek = true
var trade_slot
var trade_card
var player_wins = 0
var computer_wins = 0
var player_cards_won_ref
var computer_cards_won_ref
var end_of_round_delay = 1.0

func _ready() -> void:
	main_ref = $".."
	card_manager_ref = $"../CardManager"
	deck_ref = $"../Deck"
	player_hand_ref = $"../PlayerHand"
	computer_hand_ref = $"../ComputerHand" 
	player_cards_won_ref = $"../player_cards_won"
	computer_cards_won_ref = $"../computer_cards_won"
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false

func delayed_function(seconds: float) -> void:
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout  # Wait for the timer to finish
	timer.queue_free()  # Clean up the timer

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
				main_ref.get_node("peek_text").text = ""
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
			deck_ref.get_node("Deck_warning").text = "Opps cant draw"
			#deck_ref.draw_card()
			
		#return result[0].collider.get_parent()

func _on_trade_pressed():
	deck_ref.replace_card(trade_slot)
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false
	#main_ref.get_node("peek_text").text = ""
	await delayed_function(0.5)
		# Flip card 1
	await delayed_function(0.3)
	$"../card_flip".play()
	$"../CardSlot".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	$"../computer_card_slot1".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	var card_1 = $"../CardSlot".card_in_the_slot.card_value
	var computer_card_1 = $"../computer_card_slot1".card_in_the_slot.card_value
	var round_1
	if card_1 == 100 and computer_card_1 == 100:
		round_1 = "Draw (both cards are jokers)"
		player_wins += 10
		computer_wins += 10
	elif card_1 == 100:
		round_1 = "Hand won by player"
		player_wins += 10
	elif computer_card_1 == 100:
		round_1 = "Hand won by computer"
		computer_wins += 10
	elif card_1 > computer_card_1:
		round_1 = "Player wins"
		player_wins += 1
	elif card_1 < computer_card_1:
		round_1 = "Computer wins"
		computer_wins += 1
	else:
		round_1 = "Draw"
	main_ref.get_node("round_1_result").text = round_1

	await delayed_function(1.5)  # Add 1-second delay

	# Flip card 2
	$"../card_flip".play()
	$"../CardSlot2".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	$"../computer_card_slot2".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	var card_2 = $"../CardSlot2".card_in_the_slot.card_value
	var computer_card_2 = $"../computer_card_slot2".card_in_the_slot.card_value
	var round_2
	if card_2 == 100 and computer_card_2 == 100:
		round_2 = "Draw (both cards are jokers)"
		player_wins += 10
		computer_wins += 10
	elif card_2 == 100:
		round_2 = "Hand won by player"
		player_wins += 10
	elif computer_card_2 == 100:
		round_2 = "Hand won by computer"
		computer_wins += 10
	elif card_2 > computer_card_2:
		round_2 = "Player wins"
		player_wins += 1
	elif card_2 < computer_card_2:
		round_2 = "Computer wins"
		computer_wins += 1
	else:
		round_2 = "Draw"
	main_ref.get_node("round_2_result").text = round_2

	await delayed_function(1.5)  # Add 1-second delay

	# Flip card 3
	$"../card_flip".play()
	$"../CardSlot3".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	$"../computer_card_slot3".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	var card_3 = $"../CardSlot3".card_in_the_slot.card_value
	var computer_card_3 = $"../computer_card_slot3".card_in_the_slot.card_value
	var round_3
	if card_3 == 100 and computer_card_3 == 100:
		round_3 = "Draw (both cards are jokers)"
		player_wins += 10
		computer_wins += 10
	elif card_3 == 100:
		round_3 = "Hand won by player"
		player_wins += 10
	elif computer_card_3 == 100:
		round_3 = "Hand won by computer"
		computer_wins += 10
	elif card_3 > computer_card_3:
		round_3 = "Player wins"
		player_wins += 1
	elif card_3 < computer_card_3:
		round_3 = "Computer wins"
		computer_wins += 1
	else:
		round_3 = "Draw"
	main_ref.get_node("round_3_result").text = round_3
	
	await delayed_function(end_of_round_delay)
	
	end_of_hand_calculation()

func _on_keep_pressed():
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false
	main_ref.get_node("peek_text").text = ""
	# Flip card 1
	await delayed_function(0.3)
	$"../card_flip".play()
	$"../CardSlot".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	$"../computer_card_slot1".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	var card_1 = $"../CardSlot".card_in_the_slot.card_value
	var computer_card_1 = $"../computer_card_slot1".card_in_the_slot.card_value
	var round_1
	if card_1 == 100 and computer_card_1 == 100:
		round_1 = "Draw (both cards are jokers)"
		player_wins += 10
		computer_wins += 10
	elif card_1 == 100:
		round_1 = "Hand won by player"
		player_wins += 10
	elif computer_card_1 == 100:
		round_1 = "Hand won by computer"
		computer_wins += 10
	elif card_1 > computer_card_1:
		round_1 = "Player wins"
		player_wins += 1
	elif card_1 < computer_card_1:
		round_1 = "Computer wins"
		computer_wins += 1
	else:
		round_1 = "Draw"
	main_ref.get_node("round_1_result").text = round_1

	await delayed_function(1.5)  # Add 1-second delay

	# Flip card 2
	$"../card_flip".play()
	$"../CardSlot2".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	$"../computer_card_slot2".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	var card_2 = $"../CardSlot2".card_in_the_slot.card_value
	var computer_card_2 = $"../computer_card_slot2".card_in_the_slot.card_value
	var round_2
	if card_2 == 100 and computer_card_2 == 100:
		round_2 = "Draw (both cards are jokers)"
		player_wins += 10
		computer_wins += 10
	elif card_2 == 100:
		round_2 = "Hand won by player"
		player_wins += 10
	elif computer_card_2 == 100:
		round_2 = "Hand won by computer"
		computer_wins += 10
	elif card_2 > computer_card_2:
		round_2 = "Player wins"
		player_wins += 1
	elif card_2 < computer_card_2:
		round_2 = "Computer wins"
		computer_wins += 1
	else:
		round_2 = "Draw"
	main_ref.get_node("round_2_result").text = round_2

	await delayed_function(1.5)  # Add 1-second delay

	# Flip card 3
	$"../card_flip".play()
	$"../CardSlot3".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	$"../computer_card_slot3".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	var card_3 = $"../CardSlot3".card_in_the_slot.card_value
	var computer_card_3 = $"../computer_card_slot3".card_in_the_slot.card_value
	var round_3
	if card_3 == 100 and computer_card_3 == 100:
		round_3 = "Draw (both cards are jokers)"
		player_wins += 10
		computer_wins += 10
	elif card_3 == 100:
		round_3 = "Hand won by player"
		player_wins += 10
	elif computer_card_3 == 100:
		round_3 = "Hand won by computer"
		computer_wins += 10
	elif card_3 > computer_card_3:
		round_3 = "Player wins"
		player_wins += 1
	elif card_3 < computer_card_3:
		round_3 = "Computer wins"
		computer_wins += 1
	else:
		round_3 = "Draw"
	main_ref.get_node("round_3_result").text = round_3
	
	await delayed_function(end_of_round_delay)
	
	end_of_hand_calculation()

func end_of_hand_calculation():
	# the total calulation of point earned and how many rounds won is calculated
	card_manager_ref.cards_in_hand[0].get_node("AnimationPlayer").play_backwards("card_flip")
	card_manager_ref.cards_in_computer_hand[0].get_node("AnimationPlayer").play_backwards("card_flip")
	card_manager_ref.cards_in_hand[1].get_node("AnimationPlayer").play_backwards("card_flip")
	card_manager_ref.cards_in_computer_hand[1].get_node("AnimationPlayer").play_backwards("card_flip")
	card_manager_ref.cards_in_hand[2].get_node("AnimationPlayer").play_backwards("card_flip")
	card_manager_ref.cards_in_computer_hand[2].get_node("AnimationPlayer").play_backwards("card_flip")
	await delayed_function(0.4)
	print("POINTS")
	print("Player: " + str(player_wins))
	print("Computer: " + str(computer_wins))
	
	if player_wins > 10 and computer_wins > 10:
		end_of_hand_draw()
	
	elif player_wins > computer_wins:
		print("player wins!!")
		player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[0], player_cards_won_ref.position, 1.0)
		deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_hand[0])
		player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[1], player_cards_won_ref.position, 1.0)
		deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_hand[1])
		player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[2], player_cards_won_ref.position, 1.0)
		deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_hand[2])
		
		computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[0], player_cards_won_ref.position, 1.0)
		deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[0])
		computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[1], player_cards_won_ref.position, 1.0)
		deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[1])
		computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[2], player_cards_won_ref.position, 1.0)
		deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[2])
		#print(deck_ref.player_won_deck)
	elif computer_wins > player_wins:
		print("Computer wins....")
		player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[0], computer_cards_won_ref.position, 1.0)
		deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_hand[0])
		player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[1], computer_cards_won_ref.position, 1.0)
		deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_hand[1])
		player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[2], computer_cards_won_ref.position, 1.0)
		deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_hand[2])
		
		computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[0], computer_cards_won_ref.position, 1.0)
		deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[0])
		computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[1], computer_cards_won_ref.position, 1.0)
		deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[1])
		computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[2], computer_cards_won_ref.position, 1.0)
		deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[2])
	else:
		end_of_hand_draw()
		
	$"../card_placed".play()
	$"../CardSlot".card_in_slot = false
	$"../CardSlot2".card_in_slot = false
	$"../CardSlot3".card_in_slot = false
	$"../computer_card_slot1".card_in_slot = false
	$"../computer_card_slot2".card_in_slot = false
	$"../computer_card_slot3".card_in_slot = false
	main_ref.get_node("round_1_result").text = ""
	main_ref.get_node("round_2_result").text = ""
	main_ref.get_node("round_3_result").text = ""
	can_peek = true
	#card_manager_ref.target_slot_index = -1
	card_manager_ref.player_slots_filled = [false, false, false]  # False = empty, True = filled
	card_manager_ref.computer_slots_filled = [false, false, false]
	card_manager_ref.cards_in_hand.clear()
	card_manager_ref.cards_in_computer_hand.clear()
	await delayed_function(1.0)
	player_wins = 0
	computer_wins = 0
	#print(player_hand_ref.player_hand)
	win_or_shuffle()

func end_of_hand_draw():
	#each "player" gets cards back
	player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[0], player_cards_won_ref.position, 1.0)
	deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_hand[0])
	player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[1], player_cards_won_ref.position, 1.0)
	deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_hand[1])
	player_hand_ref.animate_card_to_position(card_manager_ref.cards_in_hand[2], player_cards_won_ref.position, 1.0)
	deck_ref.player_won_deck.insert(0,card_manager_ref.cards_in_hand[2])
	
	computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[0], computer_cards_won_ref.position, 1.0)
	deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[0])
	computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[1], computer_cards_won_ref.position, 1.0)
	deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[1])
	computer_hand_ref.animate_card_to_position(card_manager_ref.cards_in_computer_hand[2], computer_cards_won_ref.position, 1.0)
	deck_ref.computer_won_deck.insert(0,card_manager_ref.cards_in_computer_hand[2])
	
func win_or_shuffle():
	if !player_hand_ref.player_hand:
		if !deck_ref.player_won_deck:
			main_ref.get_node("peek_text").text = "You Lose"
		else:
			deck_ref.shuffle_player_won_deck()
	if !computer_hand_ref.computer_hand:
		if !deck_ref.computer_won_deck:
			main_ref.get_node("peek_text").text = "Computer Loses"
		else:
			deck_ref.shuffle_computer_won_deck()
		








