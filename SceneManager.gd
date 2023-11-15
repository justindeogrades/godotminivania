extends Node

var queued_scene_path = " ";
var current_scene_node : Node2D
var player : Node2D;


# Called when the node enters the scene tree for the first time.
func _ready():
	queued_scene_path = Global.purple_level_scene_path;
	current_scene_node = load(queued_scene_path).instantiate()
	$Levels.add_child(current_scene_node);
	#var player = load("res://Characters/Player.tscn").instantiate()
	#add_child(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_scene_to(scene_path):
	queued_scene_path = scene_path;
	current_scene_node.queue_free();
	current_scene_node = load(queued_scene_path).instantiate()
	$Levels.call_deferred("add_child", current_scene_node);
	#add_child(current_scene_node);
