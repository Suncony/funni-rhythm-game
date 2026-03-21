extends Node


var rank: String
var accuracy: float

var score: int

var perfect_count: int
var good_count: int
var bad_count: int
var miss_count: int

func clear():
	rank = ""
	accuracy = 0.0
	
	score = 0
	
	perfect_count = 0
	good_count = 0
	bad_count = 0
	miss_count = 0
