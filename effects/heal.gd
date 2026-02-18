class_name Heal
extends Effect

## Heals each target for a set amount.

@export var amount: int = 4


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target.has_method("heal"):
			target.heal(amount)

	if sound:
		SfxPlayer.play(sound)
