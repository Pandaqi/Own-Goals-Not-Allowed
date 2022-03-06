extends Node2D

@onready var field_manager = $Fields
@onready var score = $Score
@onready var players = $Players
@onready var gameover = $GameOver
@onready var BG = $BG
@onready var camera = $Camera2D
@onready var powerups = $Powerups

signal on_resize(size)

var RESCALING_VIEWPORT : bool = GDict.cfg.rescale_viewport
var PREDEFINED_WINDOW_SIZE : Vector2 = GDict.cfg.predefined_window_size

func _ready():
	randomize()
	
	if GInput.get_player_count() <= 0:
		GInput.create_debugging_players()
	
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
