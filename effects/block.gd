class_name Block
extends Effect

## Grants block to each target. Respects the target's Dexterity stat.

@export var amount: int = 5


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target.has_method("apply_block"):
			target.apply_block(amount)

	if sound:
		SfxPlayer.play(sound)
