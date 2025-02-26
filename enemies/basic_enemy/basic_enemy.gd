class_name BasicEnemy
extends CharacterBody2D

#region nodes

@export_group("Variables")
@export_range(0.0, 4096.0, 1.0, "or_greater", "suffix:px") var notice_range: float = 2048.0
@export_group("Nodes")
@export var update_timer: Timer
@export var sprite: Sprite2D
@export var hurt_sfx: FancySFX2D
@export var hurt_particles1: GPUParticles2D
@export var hurt_particles2: GPUParticles2D
@export var hurtbox: Hurtbox
@export var hitbox: Hitbox

#endregion

var dissolve_tween: Tween
var tint_tween: Tween


func _physics_process(_delta: float) -> void:
	pass


func get_hit(attack_hitbox: Hitbox):
	hurtbox.monitoring = false
	hitbox.monitorable = false
	hurt_sfx.play_sfx()
	var hit_angle: float = (
			attack_hitbox.owner.velocity.angle() if attack_hitbox.owner is CharacterBody2D
			else -global_position.direction_to(attack_hitbox.global_positon).angle()
	)
	hurt_particles1.rotation = hit_angle
	hurt_particles2.rotation = hit_angle
	hurt_particles1.restart()
	hurt_particles2.restart()
	dissolve_tween = get_tree().create_tween()
	dissolve_tween.tween_method(func(value: float):
		sprite.material.set_shader_parameter("amount", value),
	0.0, 1.0, 0.25)
	tint_tween = get_tree().create_tween()
	tint_tween.tween_method(func(value: float):
		sprite.material.set_shader_parameter("tint_amount", value),
	0.0, 1.0, 0.2)
	tint_tween.tween_method(func(value: float):
		sprite.material.set_shader_parameter("tint_amount", value),
	1.0, 0.5, 0.5)
	dissolve_tween.tween_callback(queue_free).set_delay(0.75)


func _on_update() -> void:
	update_timer.wait_time = randf_range(0.3, 0.7)
