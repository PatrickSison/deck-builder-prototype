extends Node

## Simple sound effect player singleton. Autoloaded as "SfxPlayer".
## Plays one-shot audio streams without needing a persistent AudioStreamPlayer node.

var _pool: Array[AudioStreamPlayer] = []
const POOL_SIZE := 8


func _ready() -> void:
	for _i in range(POOL_SIZE):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)


func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player := _get_free_player()
	if player == null:
		return
	player.stream    = stream
	player.volume_db = volume_db
	player.play()


func _get_free_player() -> AudioStreamPlayer:
	for p in _pool:
		if not p.playing:
			return p
	## All players busy – steal the oldest (first in pool)
	return _pool[0]
