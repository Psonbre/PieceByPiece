extends Node

@onready var label = $"../piecesCaught"
@onready var texture = $"../TextureRect"
@onready var animation = $"../TextureRect/AnimationPlayer"
@onready var finalImageTimer = $"../FinalImageTimer"

var isPuzzleCompleted : bool = false

func _ready() -> void:
	var nbPieces : int = SubsystemManager.get_collectible_manager().get_pieces_caught()
	var pieces_array : Array[Node] = getPuzzlePieces()
	nbPieces = clamp(nbPieces, 0, pieces_array.size())
	label.text = str(nbPieces) +"/12 pieces"
	for i in range(nbPieces):
		pieces_array[i].visible = true

func getPuzzlePieces() -> Array[Node]:
	var puzzle_pieces_array: Array[Node] = []
	
	for child in get_children():
		puzzle_pieces_array.append(child)
	
	return puzzle_pieces_array

func checkIfPuzzleComplete() -> void:
	for piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece is PuzzlePiece:
			if !piece.has_all_sides_connected():
				return
	puzzleCompleted()
	
func puzzleCompleted() -> void:
	isPuzzleCompleted = true
	movePuzzlePieces()

func _on_timer_timeout() -> void:
	if !isPuzzleCompleted: checkIfPuzzleComplete()
	
func movePuzzlePieces() -> void:
	# Get all pieces in the group "PuzzlePieces"
	var pieces = get_tree().get_nodes_in_group("PuzzlePieces")

	for piece in pieces:
		if piece is PuzzlePiece:
			# Start the coroutine to move the piece to its ending position
			# We just need to call the function directly, not store its return value
			move_piece_to_end_position(piece)
	
	finalImageTimer.start()

func move_piece_to_end_position(piece: PuzzlePiece) -> void:
	var ending_position = piece.ending_position  # Assuming ending_position is defined in PuzzlePiece
	var duration: float = 2.0  # Duration for the movement in seconds

	# Call the coroutine to move the piece smoothly
	await move_piece(piece, ending_position, duration)

# Coroutine to move the piece smoothly
func move_piece(piece: PuzzlePiece, target_position: Vector2, duration: float) -> void:
	var start_position = piece.position
	var elapsed_time = 0.0

	# Main loop to gradually move the piece
	while elapsed_time < duration:
		# Calculate the interpolation factor (t)
		var t = elapsed_time / duration

		# Interpolate position between start and target
		piece.position = start_position.lerp(target_position, t)

		# Wait for the next frame and accumulate elapsed time
		elapsed_time += get_process_delta_time()
		await get_tree().create_timer(0).timeout

	# Ensure the piece ends exactly at the target position
	piece.position = target_position

# Helper function to wait for all coroutines to complete
func wait_for_coroutines(coroutines: Array) -> void:
	for coroutine in coroutines:
		await coroutine  # Wait for each coroutine to finish

func displayFinalimage() -> void:
	texture.visible = true
	animation.play("fade_in")


func _on_final_image_timer_timeout() -> void:
	print("test")
	displayFinalimage()
