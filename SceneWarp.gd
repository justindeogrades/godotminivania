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


func _on_body_entered(body):
	Global.warp_pos = warp_to_pos
	Global.warp_dir = body.direction.x;
	emit_signal("player_entered");
	get_tree().get_root().get_node("SceneManager").get_node("LevelTransition").begin_scene_transition(warp_to_scene_path);
