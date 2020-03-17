extends "res://entities/player/player_controller.gd"

var backpoints: Array
export var numpoints: int = 10
export var delay: float = 1.0
var internal_delay = 0
var tween_tp: Tween
var is_using_e = false
var current_point = 0
export var cooldown: float = 5.0
var cooldown_timer: Timer
var spriteDebug = preload("res://scenes/DebugSprite.tscn")

signal use_e_ability

var debug_array: Array
export var debug_mode: bool

func store_transform():
	backpoints.push_front(self.global_transform)
	
	if debug_mode:
		var spr = spriteDebug.instance()
		get_tree().current_scene.add_child(spr)
		spr.global_transform = self.global_transform
		debug_array.push_front(spr)
	
	if backpoints.size() > numpoints :
		backpoints.pop_back()
		if debug_mode:
			debug_array.pop_back().free()

# Called when the node enters the scene tree for the first time.
func _ready():
	tween_tp = get_node("Tween") as Tween
	cooldown_timer = Timer.new()
	cooldown_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.start()
	connect("use_e_ability", self, "_on_use_e_ability_use")
	tween_tp.connect("tween_completed", self, "_on_Tween_completed")

func _physics_process(delta: float):
	if not is_using_e:
		move_axis.x = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
		move_axis.y = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	internal_delay += delta
	print(cooldown_timer.time_left)
	if internal_delay > delay and is_using_e == false:
		store_transform()
		internal_delay = 0

	if Input.is_action_just_pressed("Ability1") and cooldown_timer.is_stopped():
		is_using_e = true
		emit_signal("use_e_ability")
		

func _on_use_e_ability_use():
	if current_point == 0:
		tween_tp.interpolate_property(self, "global_transform", global_transform, backpoints[current_point], 0.5, Tween.TRANS_EXPO, Tween.EASE_IN,0.2)
	elif current_point == backpoints.size()-1:
		tween_tp.interpolate_property(self, "global_transform", global_transform, backpoints[current_point], 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT,0.2)
	else:
		tween_tp.interpolate_property(self, "global_transform", global_transform, backpoints[current_point], 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0 )
	tween_tp.start()

func _on_Tween_completed(object, key):
	print("completed")
	if current_point == backpoints.size()-1:
		backpoints.clear()
		current_point = 0
		is_using_e = false
		cooldown_timer.wait_time = cooldown
		cooldown_timer.start()
		
		if debug_mode:
			for spr in debug_array:
				spr.free()
			debug_array.clear()
		return

	current_point += 1
	emit_signal("use_e_ability")
