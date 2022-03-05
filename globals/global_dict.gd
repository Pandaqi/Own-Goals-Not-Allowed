extends Node

var version_number : String = "v0.5"
var major_version : String = "alpha"

var cfg = {
	'num_points_to_win': 50,
	'colors': {
		'teams': [
			Color(0,0,1),
			Color(1,0,1)
		],
		'ball': Color(1,0,0)
	}
}



var player_data = [
	{ 'team': 0, 'face': 5,'active': true },
	{ 'team': 1, 'face': 3, 'active': true }
]
