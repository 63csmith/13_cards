extends Node2D

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2

var player_deck = ["1","2","3"]
var card_db_ref 


func _ready() -> void:
	card_db_ref = preload("res://Scripts/card_DB.gd")

func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$"Deck img".visible = false
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	new_card.name = "card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
