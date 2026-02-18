class_name DeckManager
extends Node

## Manages a player's deck during combat:
## draw pile → hand → discard pile (→ shuffle back → draw pile)
##
## Add this as a child of the Player node. Call start_combat() once per fight.

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []
var exhaust_pile: Array[CardData] = []

var _max_hand_size: int = 10


func start_combat(deck: Array[CardData], max_hand: int) -> void:
	_max_hand_size = max_hand
	draw_pile = deck.duplicate()
	hand.clear()
	discard_pile.clear()
	exhaust_pile.clear()
	_shuffle(draw_pile)
	_emit_counts()


func draw(amount: int) -> void:
	## Draw up to `amount` cards, shuffling the discard into the draw pile
	## if the draw pile runs out mid-draw.
	var drawn := 0
	while drawn < amount:
		if hand.size() >= _max_hand_size:
			break
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break  ## No cards left anywhere
			_recycle_discard()
		if draw_pile.is_empty():
			break
		var card: CardData = draw_pile.pop_back()
		hand.append(card)
		Events.card_drawn.emit(card)
		drawn += 1

	Events.hand_updated.emit(hand.duplicate())
	_emit_counts()


func discard_card(card: CardData) -> void:
	hand.erase(card)
	discard_pile.append(card)
	Events.card_discarded.emit(card)
	Events.hand_updated.emit(hand.duplicate())
	_emit_counts()


func discard_hand() -> void:
	## Move all cards from hand to discard at end of turn.
	for card in hand:
		discard_pile.append(card)
		Events.card_discarded.emit(card)
	hand.clear()
	Events.hand_updated.emit(hand.duplicate())
	_emit_counts()


func exhaust_card(card: CardData) -> void:
	## Remove the card from the game for this combat.
	hand.erase(card)
	exhaust_pile.append(card)
	Events.card_exhausted.emit(card)
	Events.hand_updated.emit(hand.duplicate())
	_emit_counts()


func get_draw_count() -> int:
	return draw_pile.size()


func get_discard_count() -> int:
	return discard_pile.size()


# --- Private ---

func _recycle_discard() -> void:
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	_shuffle(draw_pile)


func _shuffle(arr: Array) -> void:
	arr.shuffle()


func _emit_counts() -> void:
	Events.deck_counts_updated.emit(draw_pile.size(), discard_pile.size())
