class_name CombatManager
extends Node

## Orchestrates the Slay-the-Spire style combat loop:
##   1. Combat starts: player draws opening hand
##   2. Player turn: energy refills, cards drawn, player plays cards
##   3. End turn: player discards hand, enemies act
##   4. Repeat until player or all enemies are dead

enum Phase { INACTIVE, PLAYER_TURN, ENEMY_TURN, BATTLE_WON, BATTLE_LOST }

var phase: Phase = Phase.INACTIVE

var player: Player = null
var enemies: Array[Enemy] = []

var _turn_number: int = 0


func start_combat(p: Player, enemy_list: Array[Enemy]) -> void:
	player = p
	enemies = enemy_list
	_turn_number = 0

	# Wire effect request signals to local handlers
	Events.request_draw_cards.connect(_on_request_draw_cards)
	Events.request_gain_energy.connect(_on_request_gain_energy)

	# Pick initial intents for all enemies
	for enemy in enemies:
		enemy.refresh_intent(_turn_number)

	Events.battle_started.emit()
	_start_player_turn()


func end_player_turn() -> void:
	if phase != Phase.PLAYER_TURN:
		return

	phase = Phase.ENEMY_TURN
	Events.player_turn_ended.emit()

	# Discard remaining hand
	player.deck_manager.discard_hand()

	# Reset player block at the start of enemy phase
	player.stats.reset_block()
	Events.player_block_changed.emit(player.stats.block)

	await _run_enemy_turns()

	# Check player death after all enemies acted
	if player.stats.is_dead():
		_end_combat_lost()
		return

	_turn_number += 1
	_start_player_turn()


# ---------------------------------------------------------------------------
# Private – turn flow
# ---------------------------------------------------------------------------

func _start_player_turn() -> void:
	phase = Phase.PLAYER_TURN

	# Refill energy
	player.stats.reset_energy()
	Events.player_energy_changed.emit(player.stats.energy, player.stats.max_energy)

	# Draw cards
	player.deck_manager.draw(player.stats.draw_per_turn)

	# Items that trigger on turn start
	player.trigger_items(ItemData.TriggerType.ON_TURN_START)

	Events.player_turn_started.emit()


func _run_enemy_turns() -> void:
	Events.enemy_turn_started.emit()

	for enemy in enemies:
		if enemy.stats.is_dead():
			continue

		# Apply enemy block reset
		enemy.stats.reset_block()

		await get_tree().create_timer(0.6).timeout

		enemy.execute_intent(player)
		Events.enemy_turn_ended.emit(enemy)

		# Refresh intent for next turn
		enemy.refresh_intent(_turn_number + 1)

		# Enemy block reset after their turn
		Events.enemy_block_changed.emit(enemy, enemy.stats.block)


func _end_combat_won() -> void:
	phase = Phase.BATTLE_WON
	Events.battle_won.emit()
	_disconnect_signals()


func _end_combat_lost() -> void:
	phase = Phase.BATTLE_LOST
	Events.battle_lost.emit()
	_disconnect_signals()


func _disconnect_signals() -> void:
	if Events.request_draw_cards.is_connected(_on_request_draw_cards):
		Events.request_draw_cards.disconnect(_on_request_draw_cards)
	if Events.request_gain_energy.is_connected(_on_request_gain_energy):
		Events.request_gain_energy.disconnect(_on_request_gain_energy)


# ---------------------------------------------------------------------------
# Card playing – called by UI when the player drags/drops a card
# ---------------------------------------------------------------------------

func try_play_card(card: CardData, selected_targets: Array[Node]) -> bool:
	## Returns true if the card was successfully played.
	if phase != Phase.PLAYER_TURN:
		return false
	if player.stats.energy < card.cost:
		return false

	# Spend energy
	player.stats.energy -= card.cost
	Events.player_energy_changed.emit(player.stats.energy, player.stats.max_energy)

	# Execute card effects
	card.execute(selected_targets)

	# Move card to discard (or exhaust)
	if card.exhaust:
		player.deck_manager.exhaust_card(card)
	else:
		player.deck_manager.discard_card(card)

	Events.card_played.emit(card, selected_targets)

	# Item triggers
	player.trigger_items(ItemData.TriggerType.ON_CARD_PLAYED)

	# Check if all enemies are dead
	_check_enemies_alive()

	return true


func _check_enemies_alive() -> void:
	var all_dead := enemies.all(func(e): return e.stats.is_dead())
	if all_dead:
		_end_combat_won()


# ---------------------------------------------------------------------------
# Signal handlers for effect requests
# ---------------------------------------------------------------------------

func _on_request_draw_cards(amount: int) -> void:
	if phase == Phase.PLAYER_TURN:
		player.deck_manager.draw(amount)


func _on_request_gain_energy(amount: int) -> void:
	if phase == Phase.PLAYER_TURN:
		player.stats.energy = min(player.stats.energy + amount, player.stats.max_energy)
		Events.player_energy_changed.emit(player.stats.energy, player.stats.max_energy)
