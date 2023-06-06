extends Panel

#const LilPlaylist := preload("./lil_playlist.gd")

@onready var minimize_button := %MinimizeButton
@onready var player_container := %PlayerContainer
@onready var widget_container := %WidgetContainer
@onready var audio_stream := %AudioStreamPlayer
@onready var music_progress_bar := %MusicProgressBar

@export var lil_playlist : LilPlaylist

var _minimized := false
var _playlist_idx := 0


func _ready() -> void:
	minimize_button.pressed.connect(_on_minimize_pressed)
	
	audio_stream.finished.connect(func():
		_playlist_idx = (_playlist_idx + 1) % lil_playlist.musics.size()
		audio_stream.stream = lil_playlist.musics[_playlist_idx]
		audio_stream.play()
		)
	
	if lil_playlist != null:
		audio_stream.stream = lil_playlist.musics[0]
		audio_stream.play()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position += event.relative


func _on_minimize_pressed() -> void:
	minimize_button.release_focus()
	if _minimized:
		var tween := create_tween()
		tween.tween_property(player_container, "custom_minimum_size", Vector2(200,0), 0.5)
		tween.parallel().tween_method(func(_v): _update_widget_size(), 0.0, 0.0, 0.5)
		tween.parallel().tween_property(self, "modulate:a", 1.0, 0.5)
		tween.tween_callback(_update_widget_size)
		_minimized = false
	else:
		var tween := create_tween()
		tween.tween_property(player_container, "custom_minimum_size", Vector2(0,0), 0.5)
		tween.parallel().tween_method(func(_v): _update_widget_size(), 0.0, 0.0, 0.5)
		tween.parallel().tween_property(self, "modulate:a", 0.5, 0.5)
		tween.tween_callback(_update_widget_size)
		_minimized = true


func _process(delta: float) -> void:
	music_progress_bar.value = (audio_stream.get_playback_position() / audio_stream.stream.get_length())


func _update_widget_size():
	await get_tree().process_frame
	widget_container.size.x = 0
	widget_container.position.x = size.x - widget_container.size.x
	size.x = widget_container.get_rect().size.x + 8
