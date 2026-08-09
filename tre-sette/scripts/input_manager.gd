extends Node2D

signal left_mouse_clicked
signal left_mouse_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4

var player_turn = false

var card_manager_reference
var deck_reference 


func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"

# gets mouse left click input
func _input(event: InputEvent) -> void:
	if player_turn or deck_reference.first_draw or $"../GameManager".round_finished:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("left_mouse_clicked")
				raycast_at_cursor()
			else:
				emit_signal("left_mouse_released")


# checks for what is under the cursor when left click
func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	
	
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		# when a card is found
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found = result[0].collider.get_parent()
			if card_found:
				print("card")
				card_manager_reference.start_drag(card_found)
			
		# when a deck is found
		elif result_collision_mask == COLLISION_MASK_DECK:
				deck_reference.draw_card()
