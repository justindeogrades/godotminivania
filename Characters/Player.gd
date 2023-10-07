extends CharacterBody2D


@export var speed = 200.0
@export var jump_velocity = -300.0
@export var dash_velocity = 500
@export var max_dash_frames = 30;

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D 
@onready var particle_emitter : GPUParticles2D = $GPUParticles2D 
@onready var camera : Camera2D = $Camera2D;
@onready var default_hitbox : CollisionShape2D = $DefaultHitbox;
@onready var dash_hitbox : CollisionShape2D = $DashHitbox;
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
	
	"particle_emitter.emitting = false;"
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif  double_jump_ready:
			velocity.y = double_jump_velocity
			emit_particle_burst(Vector3(0,1,0));
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
		default_hitbox.disabled = true;
		dash_hitbox.disabled = false;
		if animated_sprite.flip_h:
			dash_velocity_multiplier = -1
		else:
			dash_velocity_multiplier = 1
		emit_particle_burst(Vector3(0,dash_velocity_multiplier,0));
		
	
	if dashing:
		velocity.x = dash_velocity * dash_velocity_multiplier;
		velocity.y = 0;
		if dash_frame > max_dash_frames:
			dash_frame = 0;
			default_hitbox.disabled = false;
			dash_hitbox.disabled = true;
			dashing = false;
		dash_frame += 1;
	
	
	update_animation()
	move_and_slide()
	detect_hazards()

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

func detect_hazards():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Hazards":
			get_tree().reload_current_scene()


func emit_particle_burst(particle_vector):
	particle_emitter.restart();
	"particle_emitter.process_material.initial_velocity_max = 100.00;"
	particle_emitter.process_material.set("direction", particle_vector);
	particle_emitter.emitting = true;


func _on_room_detector_area_entered(area):
	var collision_shape = area.get_node("CollisionShape2D");
	var size = collision_shape.shape.extents * 2;
	camera.limit_top = collision_shape.global_position.y - size.y / 2;
	camera.limit_bottom = collision_shape.global_position.y + size.y / 2;
	camera.limit_left = collision_shape.global_position.x - size.x / 2;
	camera.limit_right = collision_shape.global_position.x + size.x / 2;
	
