class_name GainEnergy
extends Effect

## Grants energy to the player when this effect executes.

@export var amount: int = 1


func execute(_targets: Array[Node]) -> void:
	Events.request_gain_energy.emit(amount)

	if sound:
		SfxPlayer.play(sound)
