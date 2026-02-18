class_name DrawCards
extends Effect

## Draws additional cards when this effect is executed.

@export var amount: int = 1


func execute(_targets: Array[Node]) -> void:
	Events.request_draw_cards.emit(amount)

	if sound:
		SfxPlayer.play(sound)
