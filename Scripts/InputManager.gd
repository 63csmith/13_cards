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
var x_cursor
var player_wins = 0
var computer_wins = 0
var player_cards_won_ref
var computer_cards_won_ref
var end_of_round_delay = 1.0
var was_joker_card_played = false
var joker_card_played_by_player = []
var joker_card_played_by_computer = []
var numb_of_jokers_played_by_player = 0
var numb_of_jokers_played_by_computer = 0
var restart_button
var lock_panel 
var can_click = true
var game_over = false

func _ready() -> void:
	main_ref = $".."
	card_manager_ref = $"../CardManager"
	deck_ref = $"../Deck"
	player_hand_ref = $"../PlayerHand"
	computer_hand_ref = $"../ComputerHand" 
	player_cards_won_ref = $"../player_cards_won"
	computer_cards_won_ref = $"../computer_cards_won"
	restart_button = $"../ResetButton"
	lock_panel = $"../LockPanel"
	x_cursor = load("res://Assets/close.png")
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false
	restart_button.visible = false
	lock_panel.visible = false

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
	if result.size() > 0 and can_click:
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
				#slot_found.card_in_the_slot.scale = Vector2(1.01, 1.01)
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
	play_hand()

func _on_keep_pressed():
	play_hand()
	
func play_hand():
	can_click = false
	$Trade.disabled = true
	$Trade.visible = false
	$Keep.disabled = true
	$Keep.visible = false
	main_ref.get_node("peek_text").text = ""
			# Flip card 1
	$"../card_flip".play()
	$"../CardSlot".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	$"../computer_card_slot1".card_in_the_slot.get_node("AnimationPlayer").play("card_flip")
	var card_1 = $"../CardSlot".card_in_the_slot.card_value
	var computer_card_1 = $"../computer_card_slot1".card_in_the_slot.card_value
	var round_1
	if card_1 == 100 and computer_card_1 == 100:
		round_1 = "Double jokers"
		player_wins += 10
		computer_wins += 10
		numb_of_jokers_played_by_player += 1
		numb_of_jokers_played_by_computer += 1
	elif card_1 == 100:
		round_1 = "Joker"
		player_wins += 10
		joker_card_played_by_player.append($"../CardSlot".card_in_the_slot) 
		was_joker_card_played = true
		numb_of_jokers_played_by_player += 1
	elif computer_card_1 == 100:
		round_1 = "Joker"
		computer_wins += 10
		joker_card_played_by_computer.append($"../computer_card_slot1".card_in_the_slot) 
		numb_of_jokers_played_by_computer += 1
		was_joker_card_played = true
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
		round_2 = "Double jokers"
		player_wins += 10
		computer_wins += 10
		numb_of_jokers_played_by_player += 1
		numb_of_jokers_played_by_computer += 1
	elif card_2 == 100:
		round_2 = "Joker"
		player_wins += 10
		joker_card_played_by_player.append($"../CardSlot2".card_in_the_slot) 
		was_joker_card_played = true
		numb_of_jokers_played_by_player += 1
	elif computer_card_2 == 100:
		round_2 = "Joker"
		computer_wins += 10
		joker_card_played_by_computer.append($"../computer_card_slot2".card_in_the_slot) 
		was_joker_card_played = true
		numb_of_jokers_played_by_computer += 1
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
		round_3 = "Double joker)"
		player_wins += 10
		computer_wins += 10
		numb_of_jokers_played_by_player += 1
		numb_of_jokers_played_by_computer += 1
	elif card_3 == 100:
		round_3 = "Joker"
		player_wins += 10
		joker_card_played_by_player.append($"../CardSlot3".card_in_the_slot) 
		was_joker_card_played = true
		numb_of_jokers_played_by_player += 1
	elif computer_card_3 == 100:
		round_3 = "Joker"
		computer_wins += 10
		joker_card_played_by_computer.insert(0,$"../computer_card_slot3".card_in_the_slot) 
		was_joker_card_played = true
		numb_of_jokers_played_by_computer += 1
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
	
	print("CHECK HERE")
	print(numb_of_jokers_played_by_player)
	print(numb_of_jokers_played_by_computer)
	print(joker_card_played_by_computer)
	print(joker_card_played_by_player)
	print("CHECK HERE")
	end_of_hand_calculation()
	
func end_of_hand_calculation():
	
	# The total calculation of points earned and how many rounds won is calculated
	for i in range(3):  # Simplify repeated calls using a loop
		card_manager_ref.cards_in_hand[i].get_node("AnimationPlayer").play_backwards("card_flip")
		card_manager_ref.cards_in_computer_hand[i].get_node("AnimationPlayer").play_backwards("card_flip")
	await delayed_function(0.4)

	print("POINTS")
	print("Player: " + str(player_wins))
	print("Computer: " + str(computer_wins))
	
	if numb_of_jokers_played_by_player > 0 and numb_of_jokers_played_by_computer > 0 and numb_of_jokers_played_by_player == numb_of_jokers_played_by_computer:
		end_of_hand_draw()
	elif player_wins > computer_wins:
		print("Player wins!!")
		
		## Burn the Joker cards the player used
		#while joker_card_played_by_player.size() > 0:
			#var card = joker_card_played_by_player[0]
			#player_hand_ref.remove_card_from_hand(card)
			#joker_card_played_by_player.erase(card)

		# Perform the draw operation for the player
		for i in range(numb_of_jokers_played_by_player * 4):
			deck_ref.draw_card()
		
		# Add cards to the player's won deck, including any Jokers not burned
		for i in range(3):
			var player_card = card_manager_ref.cards_in_hand[i]
			var computer_card = card_manager_ref.cards_in_computer_hand[i]

			# Player card
			if is_joker(player_card):
				player_hand_ref.animate_card_to_position(player_card, player_cards_won_ref.position, 1.0)
				deck_ref.player_won_deck.append(player_card)
				deck_ref.player_won_deck.erase(player_card)
				player_card.queue_free()
			else:
				player_hand_ref.animate_card_to_position(player_card, player_cards_won_ref.position, 1.0)
				deck_ref.player_won_deck.append(player_card)

			# Computer card
			if is_joker(computer_card):
				computer_hand_ref.animate_card_to_position(computer_card, player_cards_won_ref.position, 1.0)
				deck_ref.player_won_deck.append(computer_card)
			else:
				computer_hand_ref.animate_card_to_position(computer_card, player_cards_won_ref.position, 1.0)
				deck_ref.player_won_deck.append(computer_card)
	elif computer_wins > player_wins:
		print("Computer wins....")
		
		# Burn the Joker cards the computer used
		#while joker_card_played_by_computer.size() > 0:
			#var card = joker_card_played_by_computer[0]
			#computer_hand_ref.remove_card_from_hand(card)
			#joker_card_played_by_computer.erase(card)

		# Perform the draw operation for the computer
		for i in range(numb_of_jokers_played_by_computer * 4):
			deck_ref.draw_computer_card()

		# Add cards to the computer's won deck, including any Jokers not burned
		for i in range(3):
			var player_card = card_manager_ref.cards_in_hand[i]
			var computer_card = card_manager_ref.cards_in_computer_hand[i]

			# Player card
			if is_joker(player_card):
				player_hand_ref.animate_card_to_position(player_card, computer_cards_won_ref.position, 1.0)
				deck_ref.computer_won_deck.append(player_card)
			else:
				player_hand_ref.animate_card_to_position(player_card, computer_cards_won_ref.position, 1.0)
				deck_ref.computer_won_deck.append(player_card)

			# Computer card
			if is_joker(computer_card):
				computer_hand_ref.animate_card_to_position(computer_card, computer_cards_won_ref.position, 1.0)
				deck_ref.computer_won_deck.append(computer_card)
				deck_ref.computer_won_deck.erase(computer_card)
				computer_card.queue_free()
			else:
				computer_hand_ref.animate_card_to_position(computer_card, computer_cards_won_ref.position, 1.0)
				deck_ref.computer_won_deck.append(computer_card)
	else:
		end_of_hand_draw()

	# Clear all card slots to prepare for the next hand
	card_manager_ref.cards_in_hand.clear()
	card_manager_ref.cards_in_computer_hand.clear()

	# Reset game state
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
	card_manager_ref.player_slots_filled = [false, false, false]
	card_manager_ref.computer_slots_filled = [false, false, false]
	await delayed_function(1.0)
	player_wins = 0
	computer_wins = 0
	numb_of_jokers_played_by_player = 0
	numb_of_jokers_played_by_computer = 0
	joker_card_played_by_player.clear()
	joker_card_played_by_computer.clear()
	
	win_or_shuffle()


# Function to check if a card is a Joker
func is_joker(card):
	return card.card_value == 100
	print(is_joker(card))

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
	
	if player_hand_ref.player_hand.size() < 3:
		can_click = false
		if !deck_ref.player_won_deck:
			main_ref.get_node("peek_text").text = "You Lose"
			lock_ui()
			can_click = false
			game_over = true
		else:
			deck_ref.shuffle_player_won_deck()
			Input.set_custom_mouse_cursor(x_cursor, 0, Vector2(64, 64))
			await delayed_function(1.0)
			Input.set_custom_mouse_cursor(null)
	if computer_hand_ref.computer_hand.size() < 3:
		can_click = false
		if !deck_ref.computer_won_deck:
			main_ref.get_node("peek_text").text = "Computer Loses"
			lock_ui()
			can_click = false
			game_over = true
		else:
			deck_ref.shuffle_computer_won_deck()
			Input.set_custom_mouse_cursor(x_cursor, 0, Vector2(64, 64))
			await delayed_function(1.0)
			Input.set_custom_mouse_cursor(null)
	if game_over:
		can_click = false
	else:
		can_click = true

func lock_ui():
	lock_panel.visible = true 
	lock_panel.z_index = 10
	restart_button.visible = true
	restart_button.z_index = 11





