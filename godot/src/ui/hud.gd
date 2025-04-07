extends Panel

@onready var score_label: Label = %ScoreLabel

func _ready():
	Events.score_changed.connect(func(score):score_label.text=str(score))
	
