extends ImmediateGeometry


const START_BEFORE : Vector3 = Vector3.DOWN
const START : Vector3 = Vector3.ZERO

var aOrD : bool = true # "angle or distance" --> TRUE=angle, FALSE=distance
var input : PoolStringArray = PoolStringArray()
var negative : bool = false
var path : PoolVector3Array = PoolVector3Array([START_BEFORE, START])

var angle : int = 0
var last : Vector3 = START

export(NodePath) onready var camera = get_node(camera) as Spatial
export(NodePath) onready var inputLabel = get_node(inputLabel) as Label
export(NodePath) onready var angleIcon = get_node(angleIcon) as TextureRect
export(NodePath) onready var distanceIcon = get_node(distanceIcon) as TextureRect


func _ready() -> void:
	updateInputIcon()
	updateInputLabel()


func _input(event: InputEvent) -> void:
	var keyEvent = event as InputEventKey
	if keyEvent and keyEvent.is_pressed():
		if keyEvent.scancode >= KEY_0 and keyEvent.scancode <= KEY_9 and input.size() < 3:
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
	if angleIcon:
		angleIcon.modulate.a = 1.0 if aOrD else 0.2
	if distanceIcon:
		distanceIcon.modulate.a = 0.2 if aOrD else 1.0


func updateInputLabel() -> void:
	if inputLabel:
		inputLabel.text = ("-" if negative else "") + (input.join("") if input.size() > 0 else "0")


func _process(delta: float) -> void:
	camera.translation = lerp(camera.translation, last, 0.03)

	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)

	for coords in path:
		add_vertex(coords)

	end()
