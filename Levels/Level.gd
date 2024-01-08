extends Node2D

var player : Node2D;
var main_menu : CanvasLayer;
var player_scene_path = ("res://Characters/Player.tscn");
var main_menu_scene_path = ("res://menus.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	player = load(player_scene_path).instantiate();
	#main_menu = load(main_menu_scene_path).instantiate()
	add_child(player);
	player.position = Global.warp_pos;
	player.direction.x = Global.warp_dir;
	if not Global.main_menu_created:
		main_menu = load(main_menu_scene_path).instantiate()
		add_child(main_menu);
	if Global.dash_on_warp:
		player.enter_dash_state();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
