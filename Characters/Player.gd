extends CharacterBody2D


@export var speed = 200.0
@export var jump_velocity = -300.0
@export var dash_velocity = 500
@export var max_dash_frames = 30;

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D 
var double_jump_velocity = jump_velocity * 0.66

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: Vector2 = Vector2.ZERO;
var double_jump_ready = true;
var dashing = false;
var dash_ready = true;
var dash_frame = 0;
var dash_velocity_multiplier = 1;
var sprite_flipped = false;

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif  double_jump_ready:
			if velocity.y <= 0:
				velocity.y += double_jump_velocity
			else:
				velocity.y = double_jump_velocity
			double_jump_ready = false
		
	if is_on_floor():
		double_jump_ready = true
		dash_ready = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down");
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
		
	if Input.is_action_just_pressed("dash") && dash_ready:
		dashing = true;
		dash_ready = false;
		dash_frame = 0;
		if animated_sprite.flip_h:
			dash_velocity_multiplier = -1
		else:
			dash_velocity_multiplier = 1
		
	
	if dashing:
		velocity.x = dash_velocity * dash_velocity_multiplier;
		velocity.y = 0;
		if dash_frame > max_dash_frames:
			dash_frame = 0;
			dashing = false;
		dash_frame += 1;
	
	
	update_animation()
	move_and_slide()

func update_animation():
	if dashing:
		animated_sprite.play("dash");
	else:
		if is_on_floor():
			if direction.x != 0:
				animated_sprite.play("walk");
			else:
				animated_sprite.play("idle");
		else:
			if velocity.y < 0:
				animated_sprite.play("jump");
			else:
				animated_sprite.play("fall");
		if direction.x < 0:
			animated_sprite.flip_h = true;
		elif direction.x > 0:
			animated_sprite.flip_h = false;
