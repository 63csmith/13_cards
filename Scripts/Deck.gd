extends Node2D

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2

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
	"joker_1", "joker_2"
];

var card_db_ref 


func _ready() -> void:
	player_deck.shuffle()
	card_db_ref = preload("res://Scripts/card_DB.gd")
	for i in range(12):
		draw_card()

func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$"Deck img".visible = false
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.get_node("card_name").text = str(card_db_ref.CARDS[card_drawn][0])
	$"../CardManager".add_child(new_card)
	new_card.name = "card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
