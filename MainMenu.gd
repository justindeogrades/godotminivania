extends VBoxContainer

var player : Node2D;
var default_colour = Color(1, 1, 1, 0.5);
var focus_colour = Color(1, 1, 1, 1);

# Called when the node enters the scene tree for the first time.
func _ready():
	$Play.call_deferred("grab_focus");
	$Play.label_settings.font_color = default_colour;
	$Options.label_settings.font_color = default_colour;
	$Quit.label_settings.font_color = default_colour;
	player = get_parent().get_parent().player;
	player.player_control = false;
	Global.main_menu_created = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_focus_entered():
	#$Play.get(theme_override_colors/font_color, Color(0, 0, 100))
	$Play.label_settings.font_color = focus_colour; 

func _on_play_focus_exited():
	$Play.label_settings.font_color = default_colour;

func _on_play_gui_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		player.player_control = true;
		get_parent().queue_free();

func _on_options_focus_entered():
	$Options.label_settings.font_color = focus_colour;

func _on_options_focus_exited():
	$Options.label_settings.font_color = default_colour;

func _on_options_gui_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		$Options.label_settings.font_size = 3;
		$Options.text = "You don't get 'options', you play the game the way I intended, fucker."


func _on_quit_focus_entered():
	$Quit.label_settings.font_color = focus_colour;

func _on_quit_focus_exited():
	$Quit.label_settings.font_color = default_colour;

func _on_quit_gui_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().quit();
