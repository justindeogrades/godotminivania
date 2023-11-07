extends Node

enum ability {
	DOUBLEJUMP,
	DASH,
	GHOST
}

var warp_pos = Vector2.ZERO;
var warp_scene_path = " ";
var warp_dir = 0;
var main_menu_created = false;
var ability_unlocked = [false, false, false];
var orbs_collected = 0;
var orbs_to_spawn_id = [true, true, true, true, true, true, true, true]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
