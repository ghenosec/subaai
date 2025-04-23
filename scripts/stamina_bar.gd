extends ProgressBar


@onready var stamina_bar = $ProgressBar
var can_regen = false
var time_to_wait = 1.5
var s_timer = 0
var can_start_stimer = true
