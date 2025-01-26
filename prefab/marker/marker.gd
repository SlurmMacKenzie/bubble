extends Node2D

var time = 0

func set_time(value: int):
	time = value
	$RichTextLabel.text = str(time)

func increase_time():
	time += 1
	$RichTextLabel.text = str(time)
