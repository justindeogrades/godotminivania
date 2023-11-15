extends Node

enum ability {
	DOUBLEJUMP,
	DASH,
	GHOST
}

var red_level_scene_path = ("res://Levels/RedLevel.tscn");
var blue_level_scene_path = ("res://Levels/BlueLevel.tscn");
var purple_level_scene_path = ("res://Levels/PurpleLevel.tscn");

var warp_pos = Vector2(0,0);
var warp_scene_path = " ";
var warp_dir = 0;
var main_menu_created = false;
var ability_unlocked = [true, true, true];
var orbs_collected = 0;
var orbs_to_spawn_id = [true, true, true, true, true, true, true, true]
var portal_active = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
