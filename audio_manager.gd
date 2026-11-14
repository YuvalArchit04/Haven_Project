extends Node

const MUSIC = preload("res://assets/Mainity Musicity.mp3")
const SFX_DEATH = preload("res://assets/Diedity.mp3")
const SFX_TICK = preload("res://assets/Tickity Timety.mp3")
const SFX_THROW = preload("res://assets/Ballity.mp3")
const SFX_RECALL = preload("res://assets/Reverse Ballity.mp3")

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var max_sfx_channels: int = 6

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	music_player = AudioStreamPlayer.new()
	music_player.stream = MUSIC
	music_player.bus = "Master"
	music_player.volume_db = -6.0
	add_child(music_player)
	
	for i in range(max_sfx_channels):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)

func play_music() -> void:
	if music_player and not music_player.playing:
		music_player.play()

func stop_music() -> void:
	if music_player and music_player.playing:
		music_player.stop()

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.play()
			return
	if sfx_players.size() > 0:
		sfx_players[0].stream = stream
		sfx_players[0].volume_db = volume_db
		sfx_players[0].play()

func play_death() -> void:
	play_sfx(SFX_DEATH, 0.0)

func play_tick() -> void:
	play_sfx(SFX_TICK, -2.0)

func play_throw() -> void:
	play_sfx(SFX_THROW, -3.0)

func play_recall() -> void:
	play_sfx(SFX_RECALL, -3.0)
