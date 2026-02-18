class_name Player
extends Node2D

## The player combat entity.
## Add to the scene tree and call setup() before starting combat.

@onready var deck_manager: DeckManager = $DeckManager

var stats: Stats = Stats.new()
var items: Array[ItemData] = []

## Set this before combat to give the player their full deck.
var character_data: CharacterData = null


func setup(char_data: CharacterData, acquired_items: Array[ItemData] = []) -> void:
	character_data = char_data
	stats = char_data.make_stats()
	items = acquired_items.duplicate()

	# Apply all passive item bonuses
	for item in items:
		if item.trigger == ItemData.TriggerType.PASSIVE:
			item.apply_passive(stats)

	# Initialise deck
	var deck := char_data.make_starting_deck()
	deck_manager.start_combat(deck, stats.hand_size)

	add_to_group("player")


func get_stats() -> Stats:
	return stats


# ---------------------------------------------------------------------------
# Combat actions
# ---------------------------------------------------------------------------

func take_damage(amount: int) -> void:
	var actual := stats.take_damage(amount)
	Events.player_health_changed.emit(stats.health, stats.max_health)
	Events.player_block_changed.emit(stats.block)
	if actual > 0:
		Events.damage_dealt.emit(self, actual)
	if stats.is_dead():
		Events.player_died.emit()


func apply_block(amount: int) -> void:
	stats.add_block(amount)
	Events.player_block_changed.emit(stats.block)


func heal(amount: int) -> void:
	stats.heal(amount)
	Events.player_health_changed.emit(stats.health, stats.max_health)


# ---------------------------------------------------------------------------
# Item system
# ---------------------------------------------------------------------------

func add_item(item: ItemData) -> void:
	items.append(item)
	if item.trigger == ItemData.TriggerType.PASSIVE:
		item.apply_passive(stats)
	Events.item_acquired.emit(item)


func trigger_items(trigger_type: ItemData.TriggerType) -> void:
	for item in items:
		if item.trigger != trigger_type:
			continue
		_apply_item_trigger(item)
		Events.item_triggered.emit(item)


func _apply_item_trigger(item: ItemData) -> void:
	if item.trigger_energy_gain > 0:
		stats.energy = min(stats.energy + item.trigger_energy_gain, stats.max_energy)
		Events.player_energy_changed.emit(stats.energy, stats.max_energy)
	if item.trigger_block_gain > 0:
		apply_block(item.trigger_block_gain)
	if item.trigger_draw_cards > 0:
		deck_manager.draw(item.trigger_draw_cards)
	if item.trigger_heal > 0:
		heal(item.trigger_heal)
