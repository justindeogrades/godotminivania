extends CanvasLayer

var scene_transitioning_to = " "
var song_to_play : AudioStreamOggVorbis;

var purple_song_path = "res://Music/purple.ogg";
var purple_song = load(purple_song_path);
var blue_song_path = "res://Music/blue.ogg";
var blue_song = load(blue_song_path);
var pink_song_path = "res://Music/pink.ogg";
var pink_song = load(pink_song_path);
var orange_song_path = "res://Music/orange.ogg";
var orange_song = load(orange_song_path);

@onready var music_player : AudioStreamPlayer = $MusicPlayer;

signal faded_to_black;
signal faded_to_level;

# Called when the node enters the scene tree for the first time.
func _ready():
	#var scene_warp = get_tree().get_node("SceneManager").get_node("Levels").get_node("SceneWarp");
	#scene_warp.player_entered.connect(_on_player_entered);
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func begin_scene_transition(_scene_transitioning_to):
	print_debug("Scene transition initiated")
	scene_transitioning_to = _scene_transitioning_to;
	fade_to_black();
	
	var fadeout_tween = get_tree().create_tween();
	fadeout_tween.tween_property($MusicPlayer, "volume_db", -80, $AnimationPlayer.get_animation("fade_to_black").length);
	#fadeout_tween.kill();

func fade_to_black():
	$AnimationPlayer.play("fade_to_black");

func fade_to_level():
	$AnimationPlayer.play("fade_to_level");


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("faded_to_black");
		get_parent().change_scene_to(scene_transitioning_to);
		change_song();
		fade_to_level();

func change_song():
	if scene_transitioning_to == Global.purple_level_scene_path:
		song_to_play = purple_song;
	elif scene_transitioning_to == Global.blue_level_scene_path:
		song_to_play = blue_song;
	elif scene_transitioning_to == Global.pink_level_scene_path:
		song_to_play = pink_song;
	elif scene_transitioning_to == Global.orange_level_scene_path:
		song_to_play = orange_song;
	
	music_player.stream = song_to_play;
	music_player.volume_db = 0;
	music_player.play();
