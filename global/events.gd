extends Node

## Global event bus. All game systems communicate through these signals
## to stay decoupled. Autoloaded as "Events".

# ---------------------------------------------------------------------------
# Card Events
# ---------------------------------------------------------------------------

## Emitted when the player successfully plays a card (energy already spent).
signal card_played(card_data: CardData, targets: Array)

## Emitted when a card is drawn into the hand.
signal card_drawn(card_data: CardData)

## Emitted when a card moves to the discard pile.
signal card_discarded(card_data: CardData)

## Emitted when a card is exhausted (permanently removed this combat).
signal card_exhausted(card_data: CardData)

## Emitted whenever the hand contents change so the UI can refresh.
signal hand_updated(hand: Array)

## Emitted whenever draw/discard pile counts change.
signal deck_counts_updated(draw: int, discard: int)

## Effects can emit this to request the DeckManager draw extra cards.
signal request_draw_cards(amount: int)

## Effects can emit this to request the CombatManager grant extra energy.
signal request_gain_energy(amount: int)

# ---------------------------------------------------------------------------
# Player Events
# ---------------------------------------------------------------------------

signal player_health_changed(health: int, max_health: int)
signal player_block_changed(block: int)
signal player_energy_changed(energy: int, max_energy: int)
signal player_died

# ---------------------------------------------------------------------------
# Enemy Events
# ---------------------------------------------------------------------------

signal enemy_health_changed(enemy: Node, health: int, max_health: int)
signal enemy_block_changed(enemy: Node, block: int)
signal enemy_died(enemy: Node)
signal enemy_intent_changed(enemy: Node, intent: Dictionary)

## Emitted when damage is dealt to any entity (for screen-shake, VFX, etc.)
signal damage_dealt(target: Node, amount: int)

# ---------------------------------------------------------------------------
# Battle Events
# ---------------------------------------------------------------------------

signal battle_started
signal player_turn_started
signal player_turn_ended
signal enemy_turn_started
signal enemy_turn_ended(enemy: Node)
signal battle_won
signal battle_lost

# ---------------------------------------------------------------------------
# Item Events
# ---------------------------------------------------------------------------

signal item_acquired(item_data: ItemData)
signal item_triggered(item_data: ItemData)

# ---------------------------------------------------------------------------
# Menu / Navigation Events
# ---------------------------------------------------------------------------

signal return_to_map
