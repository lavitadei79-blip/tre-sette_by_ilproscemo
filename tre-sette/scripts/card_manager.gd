extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var screen_size
var chosen_card
var is_hovering_card
var player_hand_reference
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	card_database_reference = preload("res://scripts/card_database.gd")
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_released", left_mouse_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# moves the clicked card to the position of the cursor
	if chosen_card:
		var mouse_pos = get_global_mouse_position()
		chosen_card.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
		clamp(mouse_pos.y, 0, screen_size.y))


#starts dragging a card
func start_drag(card):
	chosen_card = card
	chosen_card.scale = Vector2(1,1)


func left_mouse_released():
	if chosen_card:
		chosen_card.scale = Vector2(1.05,1.05)
		stop_drag()

# releases a card and lets it return to its hand position
func stop_drag():
	var card_slot_found = raycast_check_for_card_slot()
	# leaves the card in the slot
	if card_slot_found and $"../CardSlot".played_cards.size() < 2:
		player_hand_reference.remove_card(chosen_card)
		chosen_card.position = card_slot_found.position
		chosen_card.get_node("Area2D/CollisionShape2D").disabled = true
		# if there are no cards in the slot
		# the card that gets put in first decides the seed to play
		if $"../CardSlot".played_cards.size() < 1:
			$"../CardSlot".played_cards.insert(0,chosen_card)
			$"../GameManager".dominant_card(chosen_card)
			# after play. makes all card collision mask default
			# so that the next round starts as new
			for i in $"../PlayerHand".player_cards.size():
				$"../PlayerHand".player_cards[i].get_node("Area2D").collision_mask = 128
			$"../GameManager".turn_giver(false)
		# if there's a card in slot
		else:
			$"../CardSlot".played_cards.insert(1,chosen_card)
			# after play. makes all card collision mask default
			# so that the next round starts as new
			for i in $"../PlayerHand".player_cards.size():
				$"../PlayerHand".player_cards[i].get_node("Area2D").collision_mask = 128
			$"../GameManager".round_winner()
			
		
		
	# if there are isn't a slot
	else:
		player_hand_reference.return_cards_to_hand_position(chosen_card)
	chosen_card = null

# gets the signal from the card when cursor is hovering on top card
func connect_card_signal(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

# 2 functions that fix a hovering bug
func on_hovered_over_card(card):
	if chosen_card:
		null
	elif !is_hovering_card:
		is_hovering_card = true
		highlight_card(card, true)
func on_hovered_off_card(card):
	if chosen_card:
		null
	else:
		highlight_card(card, false)
		var hovering_new_card = raycast_check_for_card()
		if hovering_new_card:
			highlight_card(hovering_new_card, true)
		else:
			is_hovering_card = false


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		# when a card is found
		if result_collision_mask == COLLISION_MASK_CARD:
			return get_card_with_highest_z_index(result)
		else:
			return null

# returns the card with the highest z index 
# to make sure the selected card is always the one on the top 
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card

# makes the cards bigger when hovered
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1
