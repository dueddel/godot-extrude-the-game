extends Spatial


const START_BEFORE : Vector3 = Vector3.DOWN
const START : Vector3 = Vector3.ZERO

var aOrD : bool = true # "angle or distance" --> TRUE=angle, FALSE=distance
var input : PoolStringArray = PoolStringArray()
var negative : bool = false
var path : PoolVector3Array = PoolVector3Array([START_BEFORE, START])

var angle : int = 0
var last : Vector3 = START

export(NodePath) onready var extrudeMesh = get_node(extrudeMesh) as ImmediateGeometry
export(NodePath) onready var camera = get_node(camera) as Spatial
export(NodePath) onready var inputLabel = get_node(inputLabel) as Label
export(NodePath) onready var angleIcon = get_node(angleIcon) as TextureRect
export(NodePath) onready var distanceIcon = get_node(distanceIcon) as TextureRect
export(NodePath) onready var overlay = get_node(overlay) as TextureRect

var playMode := false setget setPlayMode


func setPlayMode(play : bool) -> void:
	if not playMode and play:
		startGame()
	if playMode and not play:
		stopGame()

	playMode = play
	if camera:
		camera.playMode = play


func _ready() -> void:
	updateInputIcon()
	updateInputLabel()


func _input(event: InputEvent) -> void:
	var keyEvent = event as InputEventKey
	if keyEvent and keyEvent.is_pressed():

		if !playMode and keyEvent.scancode != KEY_CONTROL and keyEvent.scancode != KEY_META and keyEvent.scancode != KEY_ALT:
			setPlayMode(!playMode)
		# TODO: remove me! --> implement actual game stop for switching the playMode
		elif keyEvent.scancode == KEY_ESCAPE:
			setPlayMode(!playMode)

		elif keyEvent.scancode >= KEY_0 and keyEvent.scancode <= KEY_9 and input.size() < 3:
			input.append(str(keyEvent.scancode - KEY_0))
		elif keyEvent.scancode == KEY_MINUS or keyEvent.scancode == KEY_PLUSMINUS:
			negative = !negative
		elif keyEvent.scancode == KEY_PLUS:
			negative = false
		elif keyEvent.scancode == KEY_BACKSPACE:
			if not input.empty():
				input.remove(input.size() - 1)
			elif negative:
				negative = false
		elif keyEvent.scancode == KEY_ENTER:
			var amount : int = (-1 if negative else 1) * int(input.join("") if input.size() > 0 else 0)

			if aOrD:
				angle += amount
			else:
				var distanceVec = Vector3.UP * amount
				var rotationVec = distanceVec.rotated(Vector3.FORWARD, deg2rad(angle))
#				print("current ", last)
#				print("angle ", angle)
#				print("amount ", amount)
#				print("distance ", distance)
#				print("rotatedDistVec ", rotatedDistance)

				var next = last + rotationVec
				path.append(next)
				last = next

			input = PoolStringArray()
			negative = false
			aOrD = !aOrD

		updateInputIcon()
		updateInputLabel()


func updateInputIcon() -> void:
	if playMode:
		if angleIcon:
			angleIcon.modulate.a = 1.0 if aOrD else 0.2
		if distanceIcon:
			distanceIcon.modulate.a = 0.2 if aOrD else 1.0
	else:
		angleIcon.modulate.a = 0.2
		distanceIcon.modulate.a = 0.2


func updateInputLabel() -> void:
	if inputLabel:
		inputLabel.text = ("-" if negative else "") + (input.join("") if input.size() > 0 else "0")
		inputLabel.modulate.a = 1.0 if playMode else 0.2


func _process(delta: float) -> void:
	camera.translation = lerp(camera.translation, last, 0.03)

	extrudeMesh.clear()
	extrudeMesh.begin(Mesh.PRIMITIVE_LINE_STRIP)

	for coords in path:
		extrudeMesh.add_vertex(coords)

	extrudeMesh.end()


func startGame() -> void:
	if overlay:
		$AnimationPlayer.play("menu_fade_out")


func stopGame() -> void:
	if overlay:
		$AnimationPlayer.play("menu_fade_in")
		yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("menu_idle")
