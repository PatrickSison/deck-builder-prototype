class_name Effect
extends Resource

## Base class for all card effects.
## Extend this and override execute() to create new effects.
## Effects extend Resource so they can be stored as .tres files and
## exported via @export on CardData.

@export var sound: AudioStream


func execute(_targets: Array[Node]) -> void:
	## Override in subclasses to implement the effect.
	pass
