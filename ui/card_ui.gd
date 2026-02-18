class_name CardUI
extends Control

## Visual representation of a single card with drag-and-drop support.
##
## Scene structure expected:
##   CardUI (Control, this script)
##     Panel
##       VBoxContainer
##         CostLabel   (Label)
##         IconRect    (TextureRect)
##         NameLabel   (Label)
##         TypeLabel   (Label)
##         Description (Label)
##
## The scene is instantiated by HandUI for each card in the player's hand.

signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_play_requested(card_data: CardData, card_ui: CardUI)

var card_data: CardData = null
var combat_manager: CombatManager = null

# Drag state
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _original_position: Vector2 = Vector2.ZERO
var _original_z_index: int = 0
var _hovered: bool = false

# Drop zone tracking
var _current_drop_zone: DropZone = null

# Nodes – assigned in _ready() by name, tolerates missing nodes gracefully
var _cost_label: Label = null
var _icon_rect: TextureRect = null
var _name_label: Label = null
var _type_label: Label = null
var _description_label: Label = null
var _panel: Panel = null

const HOVER_LIFT: float = -30.0
const DRAG_Z: int = 100


func _ready() -> void:
	_panel          = find_child("Panel", true, false)
	_cost_label     = find_child("CostLabel", true, false)
	_icon_rect      = find_child("IconRect", true, false)
	_name_label     = find_child("NameLabel", true, false)
	_type_label     = find_child("TypeLabel", true, false)
	_description_label = find_child("Description", true, false)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func setup(data: CardData, manager: CombatManager) -> void:
	card_data = data
	combat_manager = manager
	_refresh_display()


func _refresh_display() -> void:
	if card_data == null:
		return
	if _cost_label:
		_cost_label.text = str(card_data.cost)
	if _name_label:
		_name_label.text = card_data.card_name
	if _type_label:
		_type_label.text = card_data.get_type_label()
	if _description_label:
		_description_label.text = card_data.description
	if _icon_rect and card_data.icon:
		_icon_rect.texture = card_data.icon


# ---------------------------------------------------------------------------
# Mouse / drag handling
# ---------------------------------------------------------------------------

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_drag()
		else:
			_end_drag()


func _begin_drag() -> void:
	if card_data == null or combat_manager == null:
		return
	if combat_manager.phase != CombatManager.Phase.PLAYER_TURN:
		return

	_is_dragging = true
	_original_position = position
	_original_z_index  = z_index
	_drag_offset = get_global_mouse_position() - global_position
	z_index = DRAG_Z

	set_process(true)
	card_drag_started.emit(self)


func _end_drag() -> void:
	if not _is_dragging:
		return
	_is_dragging = false
	z_index = _original_z_index
	set_process(false)

	card_drag_ended.emit(self)

	# Try to play the card via the active drop zone
	if _current_drop_zone and _current_drop_zone.accepts_card(card_data):
		var targets := _current_drop_zone.get_targets()
		combat_manager.try_play_card(card_data, targets)
		# card_played signal will cause HandUI to remove this node
	else:
		# Snap back to original position
		_animate_return()

	_clear_drop_zone_highlight()


func _process(_delta: float) -> void:
	if _is_dragging:
		global_position = get_global_mouse_position() - _drag_offset
		_update_drop_zone_highlight()


func _animate_return() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", _original_position, 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


# ---------------------------------------------------------------------------
# Drop zone detection
# ---------------------------------------------------------------------------

func _update_drop_zone_highlight() -> void:
	var new_zone := _get_drop_zone_at_cursor()
	if new_zone == _current_drop_zone:
		return

	_clear_drop_zone_highlight()
	_current_drop_zone = new_zone
	if _current_drop_zone:
		_current_drop_zone.highlight(card_data)


func _get_drop_zone_at_cursor() -> DropZone:
	var drop_zones := get_tree().get_nodes_in_group("drop_zones")
	for zone in drop_zones:
		var z := zone as DropZone
		if z and z.get_global_rect().has_point(get_global_mouse_position()):
			return z
	return null


func _clear_drop_zone_highlight() -> void:
	if _current_drop_zone:
		_current_drop_zone.clear_highlight()
	_current_drop_zone = null


# ---------------------------------------------------------------------------
# Hover visual
# ---------------------------------------------------------------------------

func _on_mouse_entered() -> void:
	if _is_dragging:
		return
	_hovered = true
	var tween := create_tween()
	tween.tween_property(self, "position:y", _original_position.y + HOVER_LIFT, 0.1)


func _on_mouse_exited() -> void:
	if _is_dragging:
		return
	_hovered = false
	var tween := create_tween()
	tween.tween_property(self, "position:y", _original_position.y, 0.1)


# ---------------------------------------------------------------------------
# Visual state
# ---------------------------------------------------------------------------

func set_playable(can_play: bool) -> void:
	## Dims the card if the player cannot afford it.
	modulate = Color.WHITE if can_play else Color(0.5, 0.5, 0.5, 0.8)
