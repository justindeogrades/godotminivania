extends CharacterBody2D


@export var speed = 100.0
@export var jump_velocity = -250.0
@export var dash_velocity = 200
@export var max_dash_frames = 20;
@export var max_ghost_frames = 180;
@export var max_powerup_frames = 30;
@export var max_ghost_cooldown_frames = 90;
@export var death_frames_to_respawn = 120;
@export var floor_pos_update_frames_interval = 10;

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var shoes_sprite : AnimatedSprite2D = $ShoesSprite  
@onready var particle_emitter : GPUParticles2D = $GPUParticles2D 
@onready var camera : Camera2D = $Camera2D;
@onready var default_hitbox : CollisionShape2D = $DefaultHitbox;
@onready var dash_hitbox : CollisionShape2D = $DashHitbox;
@onready var animation_player : AnimationPlayer = $AnimationPlayer;
@onready var gui : CanvasLayer = $Gui
@onready var tooltip_timer : Timer = $TooltipTimer;
@onready var ghost_bar : ProgressBar = $GhostBar;

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
var powering_up = false;
var powerup_frame = 0;
var portalling = false;
var sprite_flipped = false;
var dead = false;
var death_frame = 0;
var player_control = true;
var last_pos_on_floor = Vector2(0, 0);
var floor_pos_update_frame = 0;
var is_in_portal_range = false;
var portal_pos = Vector2.ZERO;
var portal_velocity = Vector2.ZERO;
var portal_velocity_multiplier = 0.25;
var portal_frames_max = 200;
var portal_frame_at = 0;

@onready var ability_tooltip = get_node("Gui").get_node("AbilityTooltip");
@onready var orb_count = get_node("Gui").get_node("OrbCount");

func _ready():
	camera.position_smoothing_enabled = false;
	direction.x = Global.warp_dir;
	rotation_degrees = 0;
	update_animation();

func _physics_process(delta):
	
	orb_count.text = "x" + str(Global.orbs_collected);
	
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
		if not dead and not is_colliding_with_tile("Ghost Tiles") and not is_on_wall():
			floor_pos_update_frame += 1;
			if floor_pos_update_frame >= floor_pos_update_frames_interval:
				last_pos_on_floor = position;
				floor_pos_update_frame = 0;
		
	if player_control and not dead:
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = jump_velocity
			elif  Global.ability_unlocked[Global.ability.DOUBLEJUMP] and double_jump_ready and not dashing:
				velocity.y = double_jump_velocity
				emit_particle_burst(Vector3(0,1,0));
				double_jump_ready = false

		direction = Input.get_vector("left", "right", "up", "down");
		if direction:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
			
		if Input.is_action_just_pressed("dash") and Global.ability_unlocked[Global.ability.DASH] and dash_ready:
			enter_dash_state();

		if dashing:
			velocity.x = dash_velocity * dash_velocity_multiplier;
			velocity.y = 0;
			if dash_frame > max_dash_frames:
				exit_dash_state();
			dash_frame += 1;
			
		if Input.is_action_just_pressed("down") and Global.ability_unlocked[Global.ability.GHOST] and ghost_ready:
			enter_ghost_state();

		if ghosted:
			ghost_bar.value = max_ghost_frames - ghost_frame;
			if ghost_frame >= max_ghost_frames:
				exit_ghost_state();
			ghost_frame += 1
		elif not ghost_ready:
			if ghost_cooldown_frame < max_ghost_cooldown_frames:
				ghost_cooldown_frame += 1;
				ghost_bar.value = ghost_cooldown_frame;
			else:
				ghost_cooldown_frame = 0;
				ghost_bar.visible = false;
				ghost_ready = true;
		
		if Input.is_action_just_pressed("up") and is_in_portal_range and Global.portal_active:
			animation_player.play("enter_portal");
			enter_portal_state();
	elif dead:
		velocity = Vector2.ZERO;
		pass
	elif powering_up:
		velocity = Vector2(0,-1);
		if(powerup_frame >= max_powerup_frames):
			exit_powerup_state();
		powerup_frame += 1;
	elif portalling:
		if portal_frame_at < portal_frames_max:
			velocity = portal_velocity;
			scale -= Vector2(0.005, 0.005);
			portal_frame_at += 1;
		else:
			velocity = Vector2.ZERO;
			visible = false;
			get_tree().quit();
	
	
	update_animation()
	move_and_slide()

func update_animation():
	if dashing:
		animated_sprite.play("dash");
		shoes_sprite.play("dash")
	elif powering_up:
		animated_sprite.play("powerup");
	elif portalling:
		animated_sprite.play("powerup");
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
	if is_colliding_with_tile("Hazards"):
		death();


func emit_particle_burst(particle_vector):
	particle_emitter.restart();
	"particle_emitter.process_material.initial_velocity_max = 100.00;"
	particle_emitter.process_material.set("direction", particle_vector);
	particle_emitter.emitting = true;
	
func switch_to_dash_hitbox():
	default_hitbox.disabled = true;
	dash_hitbox.disabled = false;
	
func switch_to_normal_hitbox():
	default_hitbox.disabled = false;
	dash_hitbox.disabled = true;
	
func death():
	exit_dash_state();
	exit_ghost_state();
	dead = true;
	player_control = false;
	animated_sprite.hide();
	emit_particle_burst(Vector2.ZERO);
	
func respawn():
	spawn_point = last_pos_on_floor;
	position = spawn_point
	death_frame = 0;
	dead = false;
	switch_to_normal_hitbox();
	animated_sprite.show();
	dashing = false;
	ghosted = false;
	player_control = true;

func enter_dash_state():
	dashing = true;
	dash_ready = false;
	dash_frame = 0;
	switch_to_dash_hitbox();
	if animated_sprite.flip_h:
		dash_velocity_multiplier = -1
	else:
		dash_velocity_multiplier = 1
	emit_particle_burst(Vector3(0,dash_velocity_multiplier,0));

func exit_dash_state():
	dash_frame = 0;
	switch_to_normal_hitbox();
	dashing = false;

func enter_ghost_state():
	ghosted = true;
	ghost_ready = false;
	shoes_sprite.show();
	set_collision_mask_value (8, true);
	get_parent().get_node("Ghost Tiles").modulate = Color(1, 1, 1, 1);
	ghost_bar.max_value = max_ghost_frames;
	ghost_bar.visible = true;

func exit_ghost_state():
	get_parent().get_node("Ghost Tiles").modulate = Color(1, 1, 1, 0.384)
	ghost_frame = 0;
	ghosted = false;
	shoes_sprite.hide();
	set_collision_mask_value (8, false);
	ghost_bar.max_value = max_ghost_cooldown_frames;

func enter_powerup_state():
	player_control = false;
	dashing = false;
	ghosted = false;
	direction.x = 0;
	powering_up = true;

func exit_powerup_state():
	powerup_frame = 0;
	player_control = true;
	powering_up = false;
	ability_tooltip.visible = true;
	tooltip_timer.start();

func enter_portal_state():
	player_control = false;
	dashing = false;
	ghosted = false;
	portal_velocity.x = (portal_pos.x - position.x) * portal_velocity_multiplier;
	portal_velocity.y = (portal_pos.y - position.y) * portal_velocity_multiplier;
	portalling = true;

func is_colliding_with_tile(tilemap_name):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == tilemap_name:
			return true;

func _on_room_detector_area_entered(area):
	if  area.is_in_group("Rooms"):
		var collision_shape = area.get_node("CollisionShape2D");
		var size = collision_shape.shape.extents * 2;
		camera.limit_top = collision_shape.global_position.y - size.y / 2;
		camera.limit_bottom = collision_shape.global_position.y + size.y / 2;
		camera.limit_left = collision_shape.global_position.x - size.x / 2;
		camera.limit_right = collision_shape.global_position.x + size.x / 2;
	elif area.is_in_group("SceneWarps"):
		player_control = false;
		gui.visible = false;
	
	if area.is_in_group("Powerups"):
		enter_powerup_state();
		if area.ability_to_unlock == Global.ability.DOUBLEJUMP:
			ability_tooltip.text = "Space again midair to double jump";
		elif area.ability_to_unlock == Global.ability.DASH:
			ability_tooltip.text = "Shift to dash";
		elif area.ability_to_unlock == Global.ability.GHOST:
			ability_tooltip.text = "S to collide with ghost tiles";
	
	if area.is_in_group("Portal"):
		is_in_portal_range = true;
		portal_pos = area.get_parent().position;


func _on_timer_timeout():
	#player_control = true;
	camera.position_smoothing_enabled = true;


func _on_tooltip_timer_timeout():
	ability_tooltip.visible = false;
