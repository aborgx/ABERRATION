class_name HudArtery
extends Control

## Bicolor Artery HUD — shows health and frenesia as a pulsating artery.

@export var health: float = 100.0
@export var frenesia: float = 0.0

# --- Colors ---
const COLOR_HEALTH: Color = Color(0.55, 0.0, 0.0)  # Crimson red
const COLOR_FRENESIA: Color = Color(0.8, 0.0, 0.2)  # Neon crimson

# --- Artery parameters ---
var artery_width: float = 200.0
var artery_height: float = 8.0
var pulse_speed: float = 1.0
var base_pulse_rate: float = 70.0  # BPM

func _ready() -> void:
	# Center on screen
	set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	offset_bottom = -50  # 50px from bottom
	offset_left = -artery_width / 2
	offset_right = artery_width / 2
	offset_top = -artery_height / 2

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var center = size / 2
	
	# Calculate pulse
	var time = Time.get_ticks_msec() / 1000.0
	var bpm = base_pulse_rate + (frenesia / 100.0) * 60  # 70-130 BPM
	var pulse = sin(time * bpm * PI / 30.0) * 0.3 + 0.7  # 0.4 to 1.0
	
	# Frenesia scale
	var frenzy_scale = 1.0 + (frenesia / 100.0) * 0.5  # 1.0 to 1.5
	
	# Draw artery background (dark)
	var bg_rect = Rect2(
		center.x - artery_width / 2,
		center.y - artery_height / 2 * frenzy_scale,
		artery_width,
		artery_height * frenzy_scale
	)
	draw_rect(bg_rect, Color(0.1, 0.1, 0.1))
	
	# Draw health portion (left side)
	var health_width = (health / 100.0) * artery_width * 0.5
	var health_rect = Rect2(
		center.x - artery_width / 2,
		center.y - artery_height / 2 * frenzy_scale,
		health_width,
		artery_height * frenzy_scale
	)
	draw_rect(health_rect, COLOR_HEALTH * pulse)
	
	# Draw frenesia portion (right side, grows from center)
	var frenesia_width = (frenesia / 100.0) * artery_width * 0.5
	var frenesia_rect = Rect2(
		center.x,
		center.y - artery_height / 2 * frenzy_scale,
		frenesia_width,
		artery_height * frenzy_scale
	)
	draw_rect(frenesia_rect, COLOR_FRENESIA * pulse)
	
	# Draw artery outline
	var outline_rect = Rect2(
		center.x - artery_width / 2,
		center.y - artery_height / 2 * frenzy_scale,
		artery_width,
		artery_height * frenzy_scale
	)
	draw_rect(outline_rect, Color.WHITE, false, 1.0)