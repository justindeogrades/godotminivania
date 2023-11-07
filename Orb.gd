extends Area2D

@export var orb_id : int;
# Called when the node enters the scene tree for the first time.
func _ready():
	if not Global.orbs_to_spawn_id[orb_id]:
		queue_free();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if area.is_in_group("RoomDetector"):
		Global.orbs_collected += 1;
		queue_free();
		Global.orbs_to_spawn_id[orb_id] = false;
