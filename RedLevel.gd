extends Node2D

var player : Node2D;
var player_scene_path = ("res://Characters/Player.tscn");
# Called when the node enters the scene tree for the first time.
func _ready():
	player = load(player_scene_path).instantiate();
	add_child(player);
	player.position = Global.warp_pos;
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
