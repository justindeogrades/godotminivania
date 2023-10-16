extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func fade_to_black():
	$AnimationPlayer.play("fade_to_black");

func fade_to_level():
	$AnimationPlayer.play("fade_to_level");
