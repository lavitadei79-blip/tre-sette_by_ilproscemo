extends Node2D

const CARD_SCENE_PATH = "res://scenes/card.tscn" 

# all the cards get put here and get called
var cards_of_deck = ["club_A","club_2","club_3","club_4","club_5","club_6","club_7", "club_donna",
"club_ciuccio","club_re","sword_A","sword_2","sword_3","sword_4","sword_5","sword_6","sword_7",
"sword_donna","sword_ciuccio","sword_re","cup_A","cup_2","cup_3","cup_4","cup_5","cup_6",
"cup_7","cup_donna","cup_ciuccio","cup_re","coin_A","coin_2","coin_3","coin_4","coin_5","coin_6",
"coin_7","coin_donna","coin_ciuccio","coin_re",]


var first_draw = true
var player_cards_drawn = 0
var opponent_cards_drawn = 0

var player_hand_reference
var opponent_hand_reference
var card_manager_reference
var card_database_reference
var game_manager_reference


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RichTextLabel.text = str(cards_of_deck.size())
	card_database_reference = preload("res://scripts/card_database.gd")
	player_hand_reference = $"../PlayerHand"
	opponent_hand_reference = $"../OpponentHand"
	card_manager_reference = $"../CardManager"
	game_manager_reference = $"../GameManager"

# when the game start this function makes it so you draw 10 cards the first time
func draw_ten():
	first_draw = false
	for i in 9:
		$"../Timer".start()
		await $"../Timer".timeout
		draw_card()
	$"../GameManager".turn_giver($"../GameManager".turn)

# initiates a card when the deck get clicked
func draw_card():
	if first_draw:
		draw_ten()
	
	# only adds cards if both hands have less than 10 cards 
	if opponent_hand_reference.opponent_cards.size() < 10 and player_hand_reference.player_cards.size() < 10:
		
		var card_scene = preload(CARD_SCENE_PATH)
		
		# choses a random card for the player from within the deck
		var card_drawn_name = cards_of_deck[randi_range(0, cards_of_deck.size()-1)]
		cards_of_deck.erase(card_drawn_name)
		var new_card = card_scene.instantiate()
		
		# loads the card's unique sprite
		var card_image_path = str("res://assets/sprites/Carte_Napoletane/" + card_drawn_name + ".png")
		new_card.get_node("CardImage").texture = load(card_image_path)
		card_manager_reference.add_child(new_card)
		new_card.name = card_drawn_name
		
		# when there are more than 5 cards the cards get positioned in an upper hand
		if player_hand_reference.player_cards.size() < 5:
			player_hand_reference.add_card_to_lower_hand(new_card)
		elif player_hand_reference.player_cards.size() < 10:
			player_hand_reference.add_card_to_upper_hand(new_card)
		
		
		# choses a random card for the opponent from within the deck
		card_drawn_name = cards_of_deck[randi_range(0, cards_of_deck.size()-1)]
		cards_of_deck.erase(card_drawn_name)
		new_card = card_scene.instantiate()
		
		# loads the card's unique sprite
		card_image_path = str("res://assets/sprites/other/blanc_card.png")
		new_card.get_node("CardImage").texture = load(card_image_path)
		card_manager_reference.add_child(new_card)
		new_card.name = card_drawn_name
		
		# when there are more than 5 cards the cards get positioned in an upper hand
		if opponent_hand_reference.opponent_cards.size() < 5:
			opponent_hand_reference.add_card_to_lower_hand(new_card)
		elif opponent_hand_reference.opponent_cards.size() < 10:
			opponent_hand_reference.add_card_to_upper_hand(new_card)
		
		if $"../GameManager".round_finished:
			$"../GameManager".round_finished = false
			$"../GameManager".turn_giver($"../GameManager".turn)
	# the text that says the number of remaining cards
	$RichTextLabel.text = str(cards_of_deck.size())
	# when the cards finish the deck disapears
	if cards_of_deck.size() == 0:
		$"../GameManager".deck_finished = true
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
