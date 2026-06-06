extends Node

@onready var quit := $Quit
@onready var sfx := $sfx
@onready var music := $music

signal cerrar

func _ready() -> void:
	quit.connect("pressed", _on_quit)
	sfx.connect("value_changed", _on_sfx_changed)
	music.connect("value_changed", _on_music_changed)
	
	# Carga valores guardados si existen
	sfx.value = Global.sfx_volume
	music.value = Global.music_volume

func _on_quit() -> void:
	emit_signal("cerrar")
	queue_free()
	
func _on_sfx_changed(value: float) -> void:
	Global.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))

func _on_music_changed(value: float) -> void:
	Global.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))
