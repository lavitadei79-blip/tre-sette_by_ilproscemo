extends Node2D

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_WIDTH = 80
const LOWER_HAND_Y_POSITION = 840
const UPPER_HAND_Y_POSITION = 715

var player_lower_hand = []
var player_upper_hand = []
var player_cards =[]
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport_rect().size.x / 2

# adds cards to the lower hand first 
func add_card_to_lower_hand(card):
	player_lower_hand.insert(0, card)
	player_cards.insert(0, card)
	update_hand_positions()

# adds cards to the upper hand after
func add_card_to_upper_hand(card):
	player_upper_hand.insert(0, card)
	player_cards.insert(0, card)
	update_hand_positions()

# assignes position to cards
func update_hand_positions():
	#assigns the position of the cards on the lower hand
	for i in range(player_lower_hand.size()):
		var new_position
		new_position = Vector2(calculate_card_lower_position(i), LOWER_HAND_Y_POSITION)
		var card = player_lower_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position)
	
	# assigns the position of the cards on the upper hand
	for i in range(player_upper_hand.size()):
		var new_position
		new_position = Vector2(calculate_card_upper_position(i), UPPER_HAND_Y_POSITION)
		var card = player_upper_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position)

# calculates the x position for cards on the lower hand
func calculate_card_lower_position(index):
	var total_width = (player_lower_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

# calculates the x position for cards on the upper hand
func calculate_card_upper_position(index):
	var total_width = (player_upper_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

# moves cards on their assigned positions
func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.3)

# this function gets called by the card manager when a card gets released
# and returns the card to its hand position
func return_cards_to_hand_position(card):
	animate_card_to_position(card, card.hand_position)

# removes card from hand when card is placed in slot
func remove_card(card):
	if card in player_lower_hand or card in player_upper_hand:
		player_cards.erase(card)
		if card.hand_position.y == LOWER_HAND_Y_POSITION:
			player_lower_hand.erase(card)
			if player_upper_hand:
				move_upper_card_to_lower_hand()
			else:
				update_hand_positions()
		elif card.hand_position.y  == UPPER_HAND_Y_POSITION:
			player_upper_hand.erase(card)
			update_hand_positions()
		$"../Deck".player_cards_drawn -= 1

# moves a card from up to down for when a lower hand card get placed in slot
func move_upper_card_to_lower_hand():
	player_lower_hand.insert(0, player_upper_hand[0])
	player_upper_hand.erase(player_upper_hand[0])
	update_hand_positions()
