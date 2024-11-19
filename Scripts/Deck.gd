extends Node2D

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 1
const NUMBER_OF_CARDS_DEALT = 12

var player_deck = [
	"2_of_spades", "2_of_hearts", "2_of_diamonds", "2_of_clubs",
	"3_of_spades", "3_of_hearts", "3_of_diamonds", "3_of_clubs",
	"4_of_spades", "4_of_hearts", "4_of_diamonds", "4_of_clubs",
	"5_of_spades", "5_of_hearts", "5_of_diamonds", "5_of_clubs",
	"6_of_spades", "6_of_hearts", "6_of_diamonds", "6_of_clubs",
	"7_of_spades", "7_of_hearts", "7_of_diamonds", "7_of_clubs",
	"8_of_spades", "8_of_hearts", "8_of_diamonds", "8_of_clubs",
	"9_of_spades", "9_of_hearts", "9_of_diamonds", "9_of_clubs",
	"10_of_spades", "10_of_hearts", "10_of_diamonds", "10_of_clubs",
	"jack_of_spades", "jack_of_hearts", "jack_of_diamonds", "jack_of_clubs",
	"queen_of_spades", "queen_of_hearts", "queen_of_diamonds", "queen_of_clubs",
	"king_of_spades", "king_of_hearts", "king_of_diamonds", "king_of_clubs",
	"ace_of_spades", "ace_of_hearts", "ace_of_diamonds", "ace_of_clubs",
	"joker", "joker"
	
	#addtional jokers for testing 🃏
	#, "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", 
	#"joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker",
	#"joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker",
	#"joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker", "joker"
];

var card_db_ref
var cards_in_hand

var player_won_deck = []
var computer_won_deck = []

func _ready() -> void:
	player_deck.shuffle()
	card_db_ref = preload("res://Scripts/card_DB.gd")
	cards_in_hand = $"../CardManager".cards_in_hand
	$"../deal".play()
	for i in range(NUMBER_OF_CARDS_DEALT):
		draw_card()
	for i in range(NUMBER_OF_CARDS_DEALT):
		draw_computer_card()
		

func draw_card():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	#print(card_drawn_name)
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$"Deck img".visible = false
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_img_path = str("res://Assets/cards/"+card_drawn_name+".png")
	new_card.card_name = card_drawn_name
	new_card.get_node("CardImg").texture = load(card_img_path)
	new_card.get_node("card_name").text = str(card_db_ref.CARDS[card_drawn_name][0])
	new_card.get_node("card_name").visible = false
	new_card.card_value = card_db_ref.CARDS[card_drawn_name][0]
	$"../CardManager".add_child(new_card)
	new_card.name = "card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	#new_card.get_node("AnimationPlayer").play("card_flip")

func draw_computer_card():
	var computer_card_drawn_name = player_deck[0]
	player_deck.erase(computer_card_drawn_name)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$"Deck img".visible = false
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_img_path = str("res://Assets/cards/"+computer_card_drawn_name+".png")
	new_card.get_node("CardImg").texture = load(card_img_path)
	new_card.get_node("card_name").text = str(card_db_ref.CARDS[computer_card_drawn_name][0])
	new_card.rotation_degrees = 180
	new_card.get_node("card_name").visible = false
	new_card.get_node("Area2D/CollisionShape2D").disabled = true
	new_card.card_value = card_db_ref.CARDS[computer_card_drawn_name][0]
	$"../CardManager".add_child(new_card)
	new_card.name = "card"
	$"../ComputerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	#new_card.get_node("AnimationPlayer").play("card_flip")

func replace_card(trade_slot):
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$"Deck img".visible = false
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_img_path = str("res://Assets/cards/"+card_drawn_name+".png")
	new_card.get_node("CardImg").texture = load(card_img_path)
	new_card.get_node("card_name").text = str(card_db_ref.CARDS[card_drawn_name][0])
	new_card.get_node("card_name").text = str(card_db_ref.CARDS[card_drawn_name][0])
	new_card.get_node("card_name").visible = false
	new_card.card_value = card_db_ref.CARDS[card_drawn_name][0]
	new_card.name = "card"
	$"../CardManager".add_child(new_card)
#animate the card being drawn from deck to card slot / trade position 



	if trade_slot.card_in_the_slot:
		# Find the index of the current card in cards_in_hand array
		var index = cards_in_hand.find(trade_slot.card_in_the_slot)
		
		#print("Look here for new debug")
		#print(cards_in_hand)
		#print(trade_slot.card_in_the_slot)
		#print(index)
		if index != -1:
			# Remove the current card from the cards_in_hand array at the found index
			cards_in_hand.remove_at(index)
		
		trade_slot.card_in_the_slot.queue_free()
	
	# Insert the new card at the same index in cards_in_hand
		cards_in_hand.insert(index, new_card)
		trade_slot.card_in_the_slot = new_card  # Set the new card as the slot's card
		new_card.position = trade_slot.position  # Place the new card in the slot's position
		new_card.get_node("Area2D/CollisionShape2D").disabled = true
		#print(cards_in_hand)  # Disable collision if needed

func shuffle_player_won_deck():
	# Shuffle the deck
	player_won_deck.shuffle()
	$"../deal".play()

	# Use a deep copy of the array to iterate through
	var deck_copy = player_won_deck.duplicate(true)

	# Iterate through the copy
	for card_drawn in deck_copy:
		if card_drawn == null:
			print("Error: card_drawn is null!")
			continue

		# Remove the card from the original deck
		player_won_deck.erase(card_drawn)

		# Add the card to the player's hand
		$"../PlayerHand".add_card_to_hand(card_drawn, CARD_DRAW_SPEED)

		# Check if card has the expected node structure
		if card_drawn.has_node("Area2D/CollisionShape2D"):
			card_drawn.get_node("Area2D/CollisionShape2D").disabled = false
		else:
			print("Warning: Card does not have the expected node structure!")

	
func shuffle_computer_won_deck():
	# Shuffle the deck
	computer_won_deck.shuffle()
	$"../deal".play()

	# Use a deep copy of the array to iterate through
	var deck_copy = computer_won_deck.duplicate(true)

	# Iterate through the copy
	for card_drawn in deck_copy:
		if card_drawn == null:
			print("Error: card_drawn is null!")
			continue

		# Remove the card from the original deck
		computer_won_deck.erase(card_drawn)

		# Add the card to the player's hand
		$"../ComputerHand".add_card_to_hand(card_drawn, CARD_DRAW_SPEED)

		# Check if card has the expected node structure
		if card_drawn.has_node("Area2D/CollisionShape2D"):
			card_drawn.get_node("Area2D/CollisionShape2D").disabled = true
		else:
			print("Warning: Card does not have the expected node structure!")
