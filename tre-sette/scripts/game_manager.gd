extends Node

var card_database_reference

var deck_finished = false
var round_finished
var last_turn
var turn
var dom_seed = null
var player_points = 0
var opponent_points = 0

func _ready() -> void:
	card_database_reference = preload("res://scripts/card_database.gd")
	turn = randf() < 0.5
	print(turn)

# give the player and the opponent their turn
func turn_giver(turn):
	
	# if PLAYERS turn
	if turn:
		print(dom_seed)
		last_turn = true
		var playable_cards = false
		# for every card in the hand check if card corresponds to the dominant seed
		for i in $"../PlayerHand".player_cards.size():
			var card = $"../PlayerHand".player_cards[i]
			var card_seed = card_database_reference.CARDS[card.name][1]
			# makes the cards with same seed as dominant able to get picked
			if card_seed == dom_seed:
				playable_cards = true
				$"../PlayerHand".player_cards[i].get_node("Area2D").collision_mask = 1
		
		# make all cards pickable if no dominant seed available
		if !playable_cards:
			for i in $"../PlayerHand".player_cards.size():
				$"../PlayerHand".player_cards[i].get_node("Area2D").collision_mask = 1
		
		$"../InputManager".player_turn = true
	
	# if OPPONENTS turn
	elif !turn:
		print(dom_seed)
		last_turn = false
		$"../InputManager".player_turn = false
		$"../OpponentAI".opponent_play()
		# gives player the turn if needed
		if $"../CardSlot".played_cards.size() == 1 :
			turn_giver(true)

# states the dominant seed for the round
func dominant_card(dom_card):
	dom_seed = card_database_reference.CARDS[dom_card.name][1]

# calculates who won the round and give points
func round_winner():
	
	# gets the played cards number
	var first_number = card_database_reference.CARDS[$"../CardSlot".played_cards[0].name][0]
	var second_number = card_database_reference.CARDS[$"../CardSlot".played_cards[1].name][0]
	print($"../CardSlot".played_cards[0])
	print($"../CardSlot".played_cards[1])
	print(first_number,"  ", second_number)
	
	# get the played cards seed
	var first_seed = card_database_reference.CARDS[$"../CardSlot".played_cards[0].name][1]
	var second_seed = card_database_reference.CARDS[$"../CardSlot".played_cards[1].name][1]
	print(first_seed,"  ", second_seed)
	
	# get the played cards points
	var first_points = card_database_reference.CARDS[$"../CardSlot".played_cards[0].name][2]
	var second_points = card_database_reference.CARDS[$"../CardSlot".played_cards[1].name][2]
	print(first_points,"  ",second_points)
	
	
	
	print(last_turn)
	# if the played cards have the same seeds
	# the card with the highest number wins
	if first_seed == second_seed:
		if last_turn:
			if first_number > second_number: 
				opponent_points += (first_points + second_points)
				turn = false
			else:
				player_points += (first_points + second_points)
				turn = true
		else:
			if first_number > second_number: 
				player_points += (first_points + second_points)
				turn = true
			else:
				opponent_points += (first_points + second_points)
				turn = false
	# if the played cards have different seeds
	# the first card played wins
	else:
		if last_turn:
			opponent_points += (first_points + second_points)
			turn = false
		else:
			player_points += (first_points + second_points)
			turn = true
	
	print(player_points, "   ", opponent_points)
	
	# deletes the played cards
	$"../CardSlot".played_cards[0].queue_free()
	$"../CardSlot".played_cards[1].queue_free()
	$"../CardSlot".played_cards.clear()
	
	round_finished = true
	dom_seed = null
	
	# manage round after deck disapears
	if $"../Deck".cards_of_deck.size() == 0 and $"../PlayerHand".player_cards.size() > 0:
		turn_giver(turn)
		
	# when all ends
	else:
		# give the last round winer 3 points
		if turn:
			player_points += 3
		else:
			opponent_points += 3
		
		# print who won
		if player_points > opponent_points:
			print("PLAYER WINS!!!!")
		else:
			print("OPPONENT WINS!!!!")
			print("UR ASS :>")
