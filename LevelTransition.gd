extends CanvasLayer

var scene_transitioning_to = " "

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
	scene_transitioning_to = _scene_transitioning_to;
	fade_to_black();

func fade_to_black():
	$AnimationPlayer.play("fade_to_black");

func fade_to_level():
	$AnimationPlayer.play("fade_to_level");


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("faded_to_black");
		get_parent().change_scene_to(scene_transitioning_to);
		fade_to_level();
