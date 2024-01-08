extends AnimatedSprite2D

@onready var particles : GPUParticles2D = $GPUParticles2D
@onready var lock_sfx : AudioStreamPlayer = $LockSfx;

var unlocked = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func unlock():
	lock_sfx.play();
	frame = 1;
	particles.restart();
	unlocked = true;

func lock():
	frame = 0;
	unlocked = false;

#func _draw():
	#draw_line(Vector2(position.x, position.y), Vector2(get_parent().position.x, get_parent().position.y), Color(255, 0, 0), 1)
