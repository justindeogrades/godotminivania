extends CharacterBody2D


@export var speed = 100.0
@export var jump_velocity = -250.0
@export var dash_velocity = 200
@export var max_dash_frames = 20;
@export var max_ghost_frames = 180;
@export var max_ghost_cooldown_frames = 90;
@export var death_frames_to_respawn = 120;
@export var floor_pos_update_frames_interval = 10;

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var shoes_sprite : AnimatedSprite2D = $ShoesSprite  
@onready var particle_emitter : GPUParticles2D = $GPUParticles2D 
@onready var camera : Camera2D = $Camera2D;
@onready var default_hitbox : CollisionShape2D = $DefaultHitbox;
@onready var dash_hitbox : CollisionShape2D = $DashHitbox;
var double_jump_velocity = jump_velocity * 0.66
var spawn_point = Vector2(0, 0);

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: Vector2 = Vector2.ZERO;
var double_jump_ready = true;
var dashing = false;
var dash_ready = true;
var dash_frame = 0;
var dash_velocity_multiplier = 1;
var ghosted = false;
var ghost_ready = true;
var ghost_frame = 0;
var ghost_cooldown_frame = 0;
var sprite_flipped = false;
var dead = false;
var death_frame = 0;
var player_control = true;
var last_pos_on_floor = Vector2(0, 0);
var floor_pos_update_frame = 0;

func _ready():
	print_debug("Player created.");

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		floor_pos_update_frame = 0;
		
	if not dead:
		detect_hazards()
		
	if dead:
		death_frame += 1
		if death_frame >= death_frames_to_respawn:
			respawn();

	if is_on_floor():
		double_jump_ready = true
		dash_ready = true
		if not dead and not is_colliding_with_tile("Ghost Tiles"):
			floor_pos_update_frame += 1;
			if floor_pos_update_frame >= floor_pos_update_frames_interval:
				last_pos_on_floor = position;
				floor_pos_update_frame = 0;
		
	if player_control:
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = jump_velocity
			elif  double_jump_ready:
				velocity.y = double_jump_velocity
				emit_particle_burst(Vector3(0,1,0));
				double_jump_ready = false

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
			
		if Input.is_action_just_pressed("down") && ghost_ready:
			ghosted = true;
			ghost_ready = false;
			shoes_sprite.show();
		
		if ghosted:
			get_parent().get_node("Ghost Tiles").modulate = Color(1, 1, 1, 1)
			set_collision_mask_value (8, true);
			if ghost_frame >= max_ghost_frames:
				get_parent().get_node("Ghost Tiles").modulate = Color(1, 1, 1, 0.384)
				ghost_frame = 0;
				ghosted = false;
				shoes_sprite.hide();
				set_collision_mask_value (8, false);
			ghost_frame += 1
		elif not ghost_ready:
			if ghost_cooldown_frame < max_ghost_cooldown_frames:
				ghost_cooldown_frame += 1;
			else:
				ghost_cooldown_frame = 0;
				ghost_ready = true;
	else:
		velocity = Vector2.ZERO;
	
	update_animation()
	move_and_slide()

func update_animation():
	if dashing:
		animated_sprite.play("dash");
		shoes_sprite.play("dash")
	else:
		if is_on_floor():
			if direction.x != 0:
				animated_sprite.play("walk");
				shoes_sprite.play("walk");
			else:
				animated_sprite.play("idle");
				shoes_sprite.play("idle");
		else:
			if velocity.y < 0:
				animated_sprite.play("jump");
				shoes_sprite.play("jump");
			else:
				animated_sprite.play("fall");
				shoes_sprite.play("fall");
		if direction.x < 0:
			animated_sprite.flip_h = true;
			shoes_sprite.flip_h = true;
		elif direction.x > 0:
			animated_sprite.flip_h = false;
			shoes_sprite.flip_h = false;

func detect_hazards():
	"""
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Hazards":
			death();
	"""
	if is_colliding_with_tile("Hazards"):
		death();


func emit_particle_burst(particle_vector):
	particle_emitter.restart();
	"particle_emitter.process_material.initial_velocity_max = 100.00;"
	particle_emitter.process_material.set("direction", particle_vector);
	particle_emitter.emitting = true;
	
func death():
	dead = true;
	player_control = false;
	animated_sprite.hide();
	shoes_sprite.hide();
	emit_particle_burst(Vector2.ZERO);
	
func respawn():
	spawn_point = last_pos_on_floor;
	position = spawn_point
	death_frame = 0;
	dead = false;
	animated_sprite.show();
	dashing = false;
	ghosted = false;
	player_control = true;

func is_colliding_with_tile(tilemap_name):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == tilemap_name:
			return true;

func _on_room_detector_area_entered(area):
	var collision_shape = area.get_node("CollisionShape2D");
	var size = collision_shape.shape.extents * 2;
	camera.limit_top = collision_shape.global_position.y - size.y / 2;
	camera.limit_bottom = collision_shape.global_position.y + size.y / 2;
	camera.limit_left = collision_shape.global_position.x - size.x / 2;
	camera.limit_right = collision_shape.global_position.x + size.x / 2;
	
