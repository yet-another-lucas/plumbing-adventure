extends AudioStreamPlayer

func _ready():
	var _connect = connect("finished", self, "queue_free")
