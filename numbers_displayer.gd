extends Label
class_name NumbersDisplayer


@export_file var file: String = ""

@export var color: Color = Color(1.0, 1.0, 1.0, 1.0)


func _ready() -> void:
	self.set_position(self.get_position() + (-self.get_size() / 2))
	set("theme_override_colors/font_color", self.color)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position:y", self.position.y - 10, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	self.queue_free()
