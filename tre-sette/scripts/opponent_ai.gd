extends Node

var card_database_reference
var opponent_hand_reference
var slot_position

#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_database_reference = preload("res://scripts/card_database.gd")
	opponent_hand_reference = $"../OpponentHand"
	slot_position = Vector2($"../CardSlot".position)

# calculates what to play depending on the dominant seed
func opponent_play():
	# if it's the first turn of the round
	if $"../CardSlot".played_cards.size() == 0:
		# calculates wich card to play
		var playing_card = opponent_hand_reference.opponent_cards[randi_range(0, opponent_hand_reference.opponent_cards.size()-1)]
		
		animate_card_to_slot(playing_card)
		# inserts the played card in the card slot
		# to calculate round winner after
		$"../CardSlot".played_cards.insert(0,playing_card)
		# make the played card seed dominant
		$"../GameManager".dominant_card(playing_card)
		opponent_hand_reference.remove_card(playing_card)
	
	
	# if it's the last turn of the round
	else:
		var seed = $"../GameManager".dom_seed
		var playable_cards = []
		var playing_card = []
		# for loop gets the cards in the hand that can be played
		for i in opponent_hand_reference.opponent_cards.size():
			var card = opponent_hand_reference.opponent_cards[i]
			var card_seed = card_database_reference.CARDS[card.name][1]
			if card_seed == seed:
				playable_cards.insert(0, opponent_hand_reference.opponent_cards[i])
		# if there are cards in hand with seed same as dominant
		if playable_cards:
			playing_card = playable_cards[randi_range(0, playable_cards.size()-1)]
			playable_cards.clear()
		# if there aren't
		else:
			playing_card = opponent_hand_reference.opponent_cards[randi_range(0, opponent_hand_reference.opponent_cards.size()-1)]
			
		animate_card_to_slot(playing_card)
		# inserts the played card in the card slot
		# to calculate round winner after
		$"../CardSlot".played_cards.insert(1,playing_card)
		opponent_hand_reference.remove_card(playing_card)
		$"../GameManager".round_winner()

# animates the card from the hand to the slot
func animate_card_to_slot(card):
	var tween = get_tree().create_tween()
	var card_image_path = str("res://assets/sprites/Carte_Napoletane/" + card.name + ".png")
	card.get_node("CardImage").texture = load(card_image_path)
	tween.tween_property(card, "position", slot_position, 0.3)
