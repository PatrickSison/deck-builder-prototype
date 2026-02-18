class_name CombatScene
extends Node2D

## Main combat scene – instantiate this to run a combat encounter.
##
## This script builds the entire combat UI programmatically so you don't
## need to hand-wire a complex scene tree in the editor. Swap out the
## character_data and enemy_data_list to change who fights who.

const CARD_UI_SCENE := preload("res://ui/card_ui.tscn")

# Override these before adding to the scene tree (or set via setup()).
var character_data: CharacterData = null
var enemy_data_list: Array[EnemyData] = []
var player_items: Array[ItemData] = []

# --- Runtime references ---
var _player: Player = null
var _enemies: Array[Enemy] = []
var _combat_manager: CombatManager = null
var _hand_ui: HandUI = null
var _combat_hud: CombatHUD = null


func setup(char_data: CharacterData, enemies: Array[EnemyData],
		items: Array[ItemData] = []) -> void:
	character_data  = char_data
	enemy_data_list = enemies
	player_items    = items


func _ready() -> void:
	if character_data == null:
		character_data = IronbadCharacter.create()
	if enemy_data_list.is_empty():
		enemy_data_list = [GoblinEnemy.create()]

	_build_scene()
	_start_combat()


# ---------------------------------------------------------------------------
# Scene construction
# ---------------------------------------------------------------------------

func _build_scene() -> void:
	_build_background()
	_build_player()
	_build_enemies()
	_build_hand_ui()
	_build_combat_hud()
	_build_field_drop_zone()


func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.10, 0.18)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = get_viewport_rect().size
	add_child(bg)
	move_child(bg, 0)


func _build_player() -> void:
	_player = Player.new()
	_player.name = "Player"

	# DeckManager must be added BEFORE Player enters the scene tree
	# so that @onready var deck_manager = $DeckManager resolves correctly.
	var deck_mgr := DeckManager.new()
	deck_mgr.name = "DeckManager"
	_player.add_child(deck_mgr)

	add_child(_player)
	_player.position = Vector2(180, 400)

	_player.setup(character_data, player_items)

	# Player visual label (placeholder for art)
	var label := Label.new()
	label.text = character_data.character_name
	label.position = Vector2(-40, -60)
	_player.add_child(label)

	# Self drop zone on player
	var drop_zone := DropZone.new()
	drop_zone.name = "SelfDropZone"
	drop_zone.zone_type = DropZone.ZoneType.PLAYER_SELF
	drop_zone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	drop_zone.size = Vector2(80, 120)
	drop_zone.position = Vector2(-40, -60)
	_player.add_child(drop_zone)


func _build_enemies() -> void:
	var viewport_size := get_viewport_rect().size
	var spacing := viewport_size.x / (enemy_data_list.size() + 1)

	for i in range(enemy_data_list.size()):
		var enemy := Enemy.new()
		enemy.name = "Enemy_%d" % i
		add_child(enemy)
		enemy.position = Vector2(spacing * (i + 1), 250)
		enemy.setup(enemy_data_list[i])
		_enemies.append(enemy)

		# Enemy visual label (placeholder)
		var label := Label.new()
		label.text = enemy_data_list[i].enemy_name
		label.position = Vector2(-30, -50)
		enemy.add_child(label)

		# Enemy health label
		var hp_label := Label.new()
		hp_label.name = "HPLabel"
		hp_label.text = "%d / %d" % [enemy.stats.health, enemy.stats.max_health]
		hp_label.position = Vector2(-30, -20)
		enemy.add_child(hp_label)

		# Intent label
		var intent_label := Label.new()
		intent_label.name = "IntentLabel"
		intent_label.text = "???"
		intent_label.position = Vector2(-30, 10)
		enemy.add_child(intent_label)

		# Drop zone covering the enemy sprite area
		var drop_zone := DropZone.new()
		drop_zone.name = "EnemyDropZone"
		drop_zone.zone_type = DropZone.ZoneType.ENEMY
		drop_zone.linked_enemy = enemy
		drop_zone.size = Vector2(80, 120)
		drop_zone.position = Vector2(-40, -60)
		enemy.add_child(drop_zone)

		# Wire health/intent updates to the simple labels
		var captured_enemy := enemy
		var captured_hp_label := hp_label
		var captured_intent_label := intent_label
		Events.enemy_health_changed.connect(
			func(e, h, m): if e == captured_enemy:
				captured_hp_label.text = "%d / %d" % [h, m])
		Events.enemy_intent_changed.connect(
			func(e, intent): if e == captured_enemy:
				captured_intent_label.text = intent.get("description", "???"))
		Events.enemy_died.connect(
			func(e): if e == captured_enemy:
				_handle_enemy_died(e))


func _build_hand_ui() -> void:
	var viewport_size := get_viewport_rect().size
	_hand_ui = HandUI.new()
	_hand_ui.name = "HandUI"
	_hand_ui.size = Vector2(viewport_size.x, 200)
	_hand_ui.position = Vector2(0, viewport_size.y - 220)
	add_child(_hand_ui)


func _build_combat_hud() -> void:
	var viewport_size := get_viewport_rect().size
	_combat_hud = CombatHUD.new()
	_combat_hud.name = "CombatHUD"
	_combat_hud.position = Vector2(viewport_size.x - 200, 10)
	_combat_hud.size = Vector2(190, 160)
	add_child(_combat_hud)

	# Energy label
	var energy_label := Label.new()
	energy_label.name = "EnergyLabel"
	energy_label.text = "Energy: 3 / 3"
	energy_label.position = Vector2(0, 0)
	_combat_hud.add_child(energy_label)

	# Draw/Discard labels
	var draw_label := Label.new()
	draw_label.name = "DrawLabel"
	draw_label.text = "Draw: 0"
	draw_label.position = Vector2(0, 30)
	_combat_hud.add_child(draw_label)

	var discard_label := Label.new()
	discard_label.name = "DiscardLabel"
	discard_label.text = "Discard: 0"
	discard_label.position = Vector2(0, 55)
	_combat_hud.add_child(discard_label)

	# End Turn button
	var end_btn := Button.new()
	end_btn.name = "EndTurnButton"
	end_btn.text = "End Turn"
	end_btn.position = Vector2(0, 90)
	end_btn.size = Vector2(120, 40)
	_combat_hud.add_child(end_btn)

	# Player HP label (top-left)
	var player_hp := Label.new()
	player_hp.name = "PlayerHPLabel"
	player_hp.position = Vector2(10, 10)
	add_child(player_hp)
	Events.player_health_changed.connect(
		func(h, m): player_hp.text = "HP: %d / %d" % [h, m])
	Events.player_block_changed.connect(
		func(b): player_hp.text = player_hp.text)  ## re-paint on block too

	# Win / Lose overlays
	var win_screen := _make_overlay("YOU WIN!", Color(0, 0.6, 0, 0.85))
	win_screen.name = "WinScreen"
	win_screen.hide()
	add_child(win_screen)

	var lose_screen := _make_overlay("YOU DIED.", Color(0.6, 0, 0, 0.85))
	lose_screen.name = "LoseScreen"
	lose_screen.hide()
	add_child(lose_screen)

	Events.battle_won.connect(func(): win_screen.show())
	Events.battle_lost.connect(func(): lose_screen.show())


func _make_overlay(message: String, bg_color: Color) -> Control:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.size = get_viewport_rect().size

	var bg := ColorRect.new()
	bg.color = bg_color
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)

	var lbl := Label.new()
	lbl.text = message
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 48)
	root.add_child(lbl)
	return root


func _build_field_drop_zone() -> void:
	## A large invisible zone in the centre that accepts AOE / EVERYONE cards.
	var zone := DropZone.new()
	zone.name = "FieldDropZone"
	zone.zone_type = DropZone.ZoneType.FIELD
	zone.size = Vector2(600, 350)
	zone.position = Vector2(100, 80)
	add_child(zone)


# ---------------------------------------------------------------------------
# Combat start
# ---------------------------------------------------------------------------

func _start_combat() -> void:
	_combat_manager = CombatManager.new()
	_combat_manager.name = "CombatManager"
	add_child(_combat_manager)

	_hand_ui.setup(_combat_manager, CARD_UI_SCENE)
	_combat_hud.setup(_combat_manager)

	var typed_enemies: Array[Enemy] = []
	for e in _enemies:
		typed_enemies.append(e as Enemy)

	_combat_manager.start_combat(_player, typed_enemies)

	# Update player HP display
	Events.player_health_changed.emit(_player.stats.health, _player.stats.max_health)


func _handle_enemy_died(enemy: Node) -> void:
	_enemies.erase(enemy)
	# CombatManager._check_enemies_alive() handles the win condition
