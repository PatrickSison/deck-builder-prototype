class_name Damage
extends Effect

## Deals damage to each target. Respects the target's block and the
## player's Strength stat (if attacker is provided).

@export var amount: int = 6
@export var hits: int = 1      ## Number of times to hit each target
@export var pierces_block: bool = false  ## If true, ignores block

var attacker: Node = null  ## Set by CombatManager before execute() is called


func execute(targets: Array[Node]) -> void:
	var bonus_strength := 0
	if attacker and attacker.has_method("get_stats"):
		bonus_strength = attacker.get_stats().strength

	for target in targets:
		if not target or not target.has_method("take_damage"):
			continue
		for _i in range(hits):
			var total := amount + bonus_strength
			if pierces_block:
				target.stats.health = max(0, target.stats.health - total)
				Events.damage_dealt.emit(target, total)
			else:
				target.take_damage(total)

	if sound:
		SfxPlayer.play(sound)
