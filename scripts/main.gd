extends Node2D

func _ready():
	Globals.start_autosave()

func _exit_tree():
	Globals.stop_autosave()
