class_name ConnectionGroup

var members : Array[PuzzlePiece] = []

func _init(piece : PuzzlePiece = null):
	add_member(piece)

func equals(other : ConnectionGroup):
	if members.size() != other.members.size() : return false
	for member in members :
		if !other.members.has(member) : return false
	return true

func add_member(piece : PuzzlePiece):
	if piece == null : return
	if !members.has(piece) : members.append(piece)
