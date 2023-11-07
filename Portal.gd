extends Node2D

@onready var ring : Sprite2D = $Ring
@onready var label : Label = $Label

var lock_scene_path = "res://lock.tscn"
var lock = [];
var lock_y_offset = 32;
var lock_x_offset = 24;
var player_in_range = false;
var lock_to_unlock = 0;
var unlock_interval_frames_max = 60;
var unlock_interval_frame_at = unlock_interval_frames_max;
var orbs_to_collect = 8;

# Called when the node enters the scene tree for the first time.
func _ready():
	lock.resize(8);
	for i in 8:
		lock[i] = load(lock_scene_path).instantiate();
		add_child(lock[i]);
		if i % 2 == 0:
			lock[i].position.x -= lock_x_offset;
			lock_y_offset -= 12;
		else:
			lock[i].position.x += lock_x_offset;
		lock[i].position.y -= lock_y_offset;
	#current_scene_node = load(queued_scene_path).instantiate()
	#$Levels.add_child(current_scene_node);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ring.rotation_degrees += 1;
	
	if player_in_range:
		if(unlock_interval_frame_at >= unlock_interval_frames_max):
			if(Global.orbs_collected > lock_to_unlock):
				lock[lock_to_unlock].unlock();
				lock_to_unlock += 1;
				unlock_interval_frame_at = 0;
			else:
				orbs_to_collect = 8 - Global.orbs_collected;
				label.text = ("Collect " + str(orbs_to_collect) + " more orbs");
				label.visible = true;
		unlock_interval_frame_at += 1;

func _on_area_2d_area_entered(area):
	if area.is_in_group("RoomDetector"):
		player_in_range = true;

func _on_area_2d_area_exited(area):
	if area.is_in_group("RoomDetector"):
		player_in_range = false;
		label.visible = false;
		reset_locks();

func reset_locks():
	for j in 8:
		lock[j].lock();
	lock_to_unlock = 0;
	unlock_interval_frame_at = unlock_interval_frames_max;
