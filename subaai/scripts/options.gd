extends Node2D
@onready var master_volume_slider = $VolumeContainer/VolumeSlider

var master_bus_idx = AudioServer.get_bus_index("Master")

func _ready():
	load_settings()
	
	master_volume_slider.value_changed.connect(self._on_master_volume_changed)

func _on_master_volume_changed(value):
	var volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus_idx, volume_db)

func _on_apply_button_pressed():
	save_settings()

func _on_back_button_pressed():
	save_settings()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("audio", "master_volume", master_volume_slider.value)
	
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err != OK:
		return
	
	if config.has_section_key("audio", "master_volume"):
		master_volume_slider.value = config.get_value("audio", "master_volume")
		_on_master_volume_changed(master_volume_slider.value)
