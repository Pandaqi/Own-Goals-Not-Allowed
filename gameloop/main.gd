extends Node2D

@onready var field_manager = $Fields
@onready var score = $Score
@onready var players = $Players
@onready var gameover = $GameOver
@onready var BG = $BG

func _ready():
	randomize()
	
	GInput.create_debugging_players()
	
	BG.activate()
	players.activate()
	field_manager.activate()
	score.activate()
	gameover.activate()
