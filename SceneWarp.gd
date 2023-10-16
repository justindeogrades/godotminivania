extends Area2D

@export var warp_to_pos = Vector2.ZERO;
@export var warp_to_scene_path = " ";

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	Global.warp_pos = warp_to_pos
	get_tree().change_scene_to_file(warp_to_scene_path);
	"""get_tree().change_scene_to_file("res://PinkLevel.tscn");"""
	print_debug(warp_to_pos)
