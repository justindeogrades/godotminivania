extends Area2D

@export var warp_to_pos = Vector2.ZERO;
@export var warp_to_scene_path = " ";

signal player_entered;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	if area.is_in_group("RoomDetector"):
		Global.warp_pos = warp_to_pos
		
		if area.get_parent().animated_sprite.flip_h:
			Global.warp_dir = -1;
		else:
			Global.warp_dir = 1;
		
		if area.get_parent().dashing:
			Global.dash_on_warp = true;
		else:
			Global.dash_on_warp = false;
		
		print_debug(str(Global.warp_dir))
		emit_signal("player_entered");
		get_tree().get_root().get_node("SceneManager").get_node("LevelTransition").begin_scene_transition(warp_to_scene_path);
