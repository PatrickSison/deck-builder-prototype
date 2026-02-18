class_name CombatHUD
extends Control

## Displays energy orbs, end turn button, and deck/discard pile counts.
##
## Expected scene children:
##   EnergyLabel   (Label)    – "3 / 3"
##   EndTurnButton (Button)
##   DrawLabel     (Label)    – draw pile count
##   DiscardLabel  (Label)    – discard pile count
##   WinScreen     (Control)  – shown on victory
##   LoseScreen    (Control)  – shown on defeat

signal end_turn_pressed

var _combat_manager: CombatManager = null

var _energy_label: Label   = null
var _end_turn_btn: Button  = null
var _draw_label: Label     = null
var _discard_label: Label  = null
var _win_screen: Control   = null
var _lose_screen: Control  = null


func _ready() -> void:
	_energy_label  = find_child("EnergyLabel", true, false)
	_end_turn_btn  = find_child("EndTurnButton", true, false)
	_draw_label    = find_child("DrawLabel", true, false)
	_discard_label = find_child("DiscardLabel", true, false)
	_win_screen    = find_child("WinScreen", true, false)
	_lose_screen   = find_child("LoseScreen", true, false)

	if _end_turn_btn:
		_end_turn_btn.pressed.connect(_on_end_turn_pressed)

	if _win_screen:
		_win_screen.hide()
	if _lose_screen:
		_lose_screen.hide()

	Events.player_energy_changed.connect(_on_energy_changed)
	Events.deck_counts_updated.connect(_on_deck_counts_updated)
	Events.player_turn_started.connect(_on_player_turn_started)
	Events.player_turn_ended.connect(_on_player_turn_ended)
	Events.battle_won.connect(_on_battle_won)
	Events.battle_lost.connect(_on_battle_lost)


func setup(manager: CombatManager) -> void:
	_combat_manager = manager
	if _energy_label:
		_energy_label.text = "Energy: 0 / 0"


func _on_end_turn_pressed() -> void:
	if _combat_manager:
		_combat_manager.end_player_turn()
	end_turn_pressed.emit()


func _on_energy_changed(energy: int, max_energy: int) -> void:
	if _energy_label:
		_energy_label.text = "Energy: %d / %d" % [energy, max_energy]


func _on_deck_counts_updated(draw: int, discard: int) -> void:
	if _draw_label:
		_draw_label.text = "Draw: %d" % draw
	if _discard_label:
		_discard_label.text = "Discard: %d" % discard


func _on_player_turn_started() -> void:
	if _end_turn_btn:
		_end_turn_btn.disabled = false


func _on_player_turn_ended() -> void:
	if _end_turn_btn:
		_end_turn_btn.disabled = true


func _on_battle_won() -> void:
	if _win_screen:
		_win_screen.show()
	if _end_turn_btn:
		_end_turn_btn.disabled = true


func _on_battle_lost() -> void:
	if _lose_screen:
		_lose_screen.show()
	if _end_turn_btn:
		_end_turn_btn.disabled = true
