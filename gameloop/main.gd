extends Node2D

@onready var field_manager = $Fields
@onready var score = $Score
@onready var players = $Players
@onready var gameover = $GameOver
@onready var BG = $BG
@onready var camera = $Camera2D
@onready var powerups = $Powerups
@onready var bots = $Bots

signal on_resize(size)

var RESCALING_VIEWPORT : bool = GDict.cfg.rescale_viewport
var PREDEFINED_WINDOW_SIZE : Vector2 = GDict.cfg.predefined_window_size

var num_players : int
var num_real_players : int

func _ready():
	randomize()
	
	if GInput.get_player_count() <= 0:
		GInput.create_debugging_players()
	
	if GInput.get_player_count() == 1:
		GDict.cfg.bots = true
	
	bots.activate()
	num_real_players = GInput.get_player_count()
	num_players = num_real_players + bots.count()

	BG.activate()
	players.activate()
	field_manager.pre_activate()
	score.activate()
	gameover.activate()
	
	get_viewport().size_changed.connect(on_viewport_changed)
	on_viewport_changed()
	
	field_manager.activate()
	powerups.activate()

func on_viewport_changed():
	var size = PREDEFINED_WINDOW_SIZE
	if RESCALING_VIEWPORT: size = get_viewport().size
	emit_signal("on_resize", size)
