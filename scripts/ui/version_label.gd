extends Label
class_name VersionLabel


var modulation_alpha: int = self.modulate.a
var use_full_opacity: bool = true
@onready var tween: Tween = null


func on_tween_finished() -> void:
	tween = create_tween()
	
	if use_full_opacity:
		modulation_alpha = 1.0
	else:
		modulation_alpha = 0.0
	
	use_full_opacity = not use_full_opacity
	
	tween.finished.connect(on_tween_finished)
	tween.tween_property(self, "modulate:a", modulation_alpha, 1)


func _ready() -> void:
	tween = create_tween()
	tween.finished.connect(on_tween_finished)
	tween.tween_property(self, "modulate:a", 0.0, 1)
	use_full_opacity = true
