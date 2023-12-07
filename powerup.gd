extends Node2D

@export var ability_to_unlock : int;
# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.ability_unlocked[ability_to_unlock]:
		queue_free();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	if area.is_in_group("RoomDetector"):
		Global.ability_unlocked[ability_to_unlock] = true;
		call_deferred("queue_free");
