extends MeshInstance


export(float, 0, 500, 10) var moveUp : float = 100
export(float, 0, 1) var startAt : float = 0.0
export(float, 0, 60) var wait : float = 3.0

var yMin : Vector3
var yMax : Vector3


func _ready() -> void:
	yMin = translation
	yMax = translation + Vector3(0, moveUp, 0)

	translation += Vector3(0, lerp(0, moveUp, startAt), 0)

	$Timer.wait_time = lerp(wait, 0, startAt)
	moveTo(yMax, $Timer.wait_time)
	$Timer.start()


func _process(delta: float) -> void:
	if $Timer.is_stopped():
		$Timer.wait_time = wait

		if translation.y <= yMin.y:
			moveTo(yMax, wait)
			$Timer.start()
		elif translation.y >= yMax.y:
			moveTo(yMin, wait)
			$Timer.start()


func moveTo(to : Vector3, duration : float):
	$Tween.interpolate_property(self, "translation", translation, to, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
