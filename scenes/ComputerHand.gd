extends Node2D


var computer_hand = []


const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_WIDTH = 100
const HAND_Y_POSITION = 100
const DEFAULT_CARD_SPEED = 0.1

var center_screen_x


func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	#var card_scene = preload(CARD_SCENE_PATH)
	#for i in range(HAND_COUNT):
		#$"../Deck".draw_card()
		#var new_card = card_scene.instantiate()
		#$"../CardManager".add_child(new_card)
		#new_card.name = "card"
		#add_card_to_hand(new_card, DEFAULT_CARD_SPEED)


func add_card_to_hand(card, speed):
	if card not in computer_hand:
		computer_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.starting_position, DEFAULT_CARD_SPEED)
	
	
	
func update_hand_positions(speed):
	for i in range(computer_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = computer_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)
		
		
func calculate_card_position(index):
	var total_width = (computer_hand.size() -1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset
	
	

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in computer_hand:
		computer_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_SPEED)
