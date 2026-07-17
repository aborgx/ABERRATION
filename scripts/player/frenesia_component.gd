class_name FrenesiaComponent
extends Node

signal frenesia_changed(old_value: int, new_value: int)
signal frenesia_level_changed(new_level: FrenesiaLevel)

var body: CharacterBody3D = null

enum FrenesiaLevel { CALM, AGITATED, FURIOUS, FRENETIC, OVERFRENESIA }

@export var max_frenesia: int = 100
@export var decay_rate: float = 2.0
@export var idle_decay_threshold: float = 5.0
@export var idle_decay_amount: int = 5

var current_frenesia: int = 0
var current_level: FrenesiaLevel = FrenesiaLevel.CALM
var time_since_last_kill: float = 0.0

const LEVEL_THRESHOLDS = {
    FrenesiaLevel.CALM: 0,
    FrenesiaLevel.AGITATED: 21,
    FrenesiaLevel.FURIOUS: 41,
    FrenesiaLevel.FRENETIC: 61,
    FrenesiaLevel.OVERFRENESIA: 81
}

const DAMAGE_MULTIPLIERS = {
    FrenesiaLevel.CALM: 1.0,
    FrenesiaLevel.AGITATED: 1.05,
    FrenesiaLevel.FURIOUS: 1.15,
    FrenesiaLevel.FRENETIC: 1.25,
    FrenesiaLevel.OVERFRENESIA: 1.50
}

const SPEED_MULTIPLIERS = {
    FrenesiaLevel.CALM: 1.0,
    FrenesiaLevel.AGITATED: 1.10,
    FrenesiaLevel.FURIOUS: 1.20,
    FrenesiaLevel.FRENETIC: 1.30,
    FrenesiaLevel.OVERFRENESIA: 1.50
}

func _ready() -> void:
    _update_level()

func _process(delta: float) -> void:
    if current_frenesia > 0:
        current_frenesia = max(0, current_frenesia - decay_rate * delta)
        time_since_last_kill += delta
        
        if time_since_last_kill >= idle_decay_threshold:
            current_frenesia = max(0, current_frenesia - idle_decay_amount)
            time_since_last_kill = 0.0
        
        _update_level()

func add_frenesia(amount: int) -> void:
    var old_frenesia = current_frenesia
    current_frenesia = clamp(current_frenesia + amount, 0, max_frenesia)
    frenesia_changed.emit(old_frenesia, current_frenesia)
    time_since_last_kill = 0.0
    _update_level()

func on_damage_taken() -> void:
    var old_frenesia = current_frenesia
    current_frenesia = max(0, current_frenesia - 10)
    frenesia_changed.emit(old_frenesia, current_frenesia)
    _update_level()

func _update_level() -> void:
    var new_level: FrenesiaLevel
    if current_frenesia >= LEVEL_THRESHOLDS[FrenesiaLevel.OVERFRENESIA]:
        new_level = FrenesiaLevel.OVERFRENESIA
    elif current_frenesia >= LEVEL_THRESHOLDS[FrenesiaLevel.FRENETIC]:
        new_level = FrenesiaLevel.FRENETIC
    elif current_frenesia >= LEVEL_THRESHOLDS[FrenesiaLevel.FURIOUS]:
        new_level = FrenesiaLevel.FURIOUS
    elif current_frenesia >= LEVEL_THRESHOLDS[FrenesiaLevel.AGITATED]:
        new_level = FrenesiaLevel.AGITATED
    else:
        new_level = FrenesiaLevel.CALM
    
    if new_level != current_level:
        current_level = new_level
        frenesia_level_changed.emit(current_level)

func get_damage_multiplier() -> float:
    return DAMAGE_MULTIPLIERS[current_level]

func get_speed_multiplier() -> float:
    return SPEED_MULTIPLIERS[current_level]