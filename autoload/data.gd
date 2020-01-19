extends Node

var attempt_numero = 0

var questions = {
	"gaming" : [
		"Sid Meier is the mastermind behind which long running series?",
		"In the Half Life series, who is the voice actor that portrays Gordon Freeman?",
		"Which of these is NOT a type of Pokemon??",

		"What country is home to game developer \"CD Projekt Red\"?",
		"What console was the original “Sonic the Hedgehog” game released on?",
		"In what game was the main focus on a town called Tristram?",

		"How many platforms has “The Elder Scrolls V: Skyrim” been officially released for?",
		"How many buttons are on the original controller for the Atari 2600?",
		"Which of the following is NOT a character from Final Fantasy 7?",
		"As of Jan 2020, how many \"Call of Duty\" games have been released on PC and consoles?"
	],

	"godot" : [
		"How much does it cost to use the Godot engine?",
		"What is the screen name for the creator of the Godot engine?",
		"How many bumps are on the Godot logo's head?",

		"What language is the Godot engine written in?",
		"Which of these is the best game engine?",
		"Who wrote the play that inspired the Godot engine's name?",

		"What continent are Godot creators Juan Linietsky and Ariel Manzur from?",
		"Which of these is NOT a Node in the Godot engine?",
		"What is the name of the game the Godot engine was originally written specifically for?",

		"As of January 2020, how many people have contributed to the Godot source code?",
	],

	"surprise" : [
		"Of the 4 GWJ developer roles, which has the most members?",
		"Which of these have never been a GWJ theme?",
		"Which of these GWJ members are NOT a Stern Flower?",

		"How often are the GWJ competitions held?",
		"How many days does the GWJ last?",
		"What is the name of GWJ\'s turtle?",

		"In which month of the year was the first GWJ held?",
		"Which of the following is NOT a rating category in GWJ?",
		"The Wildling, the mascot of the GWJ, is a hybrid of which two animals?",

		"Which of the following games will definitely win GWJ17?"

	]
}

var answers = {
	"gaming" : [
		["The Sims", "Civilization", "Fallout", "XCOM",1],
		["Nolan North", "Norman Reeduz", "David Hayter", "None of the above",3],
		["Psychic", "Space", "Dark", "Ghost",1],

		["Poland", "Ukraine", "United States", "Russia",0],
		["Sega Saturn", "Sega Master Drive", "Sega Genesis", "Sega Dreamcast",2],
		["Baldur's Gate'", "Skyrim", "Dragon Age", "Diablo",3],

		["Three", "Six", "Four", "Five",1],
		["Zero", "One", "Two", "Three",1],
		["Rude", "Cloud", "Squall", "Red XIII",2],
		["19", "15", "17", "21",0],
	],

	"godot" : [
		["500$ for a commercial license", "5% Revenue Share","Nothing at all", "5000 Pesos",2],
		["redos", "reduz", "redooz", "reduze",1],
		["Four", "Three", "Five", "Eight",0],

		["C#", "Java", "C++", "Python",2],
#		["2017", "2007", "2010", "2014",3],
		["Godot Engine", "Game Maker", "Source Engine", "Creation Engine",0],
		["Arthur Miller", "Samuel Beckett", "Oscar Wilde", "Ariel Manzur",1],

		["South America", "Europe", "North America", "Australia",2],
		["VehicleWheel", "GridMap", "ParticleAttractor", "PinJoint2D",2],
		["Zero", "One", "Two", "Three",3],

		["About 10", "About 100", "About 1.000", "About 10.000",2]
	],
	"surprise" : [
		["Designer", "Composer", "Programmer", "Artist",2],
		["Laser", "Shadow", "Floating Island", "Glitch",0],
		["Krystof", "D4yz", "Dawk", "Irmoz",1],

		["Once a year", "Every two months", "Once a month", "Once a week",2],
		["Twelve", "Nine", "Six", "Three",1],
		["Snap", "Groovy", "Bill", "Carl",3],

		["Originality", "Theme", "Atmosphere", "Fun",2],
		["September ", "Oktober", "November", "December",0],
		["Peach", "Toad", "Daisy", "Koopa Troopa",2],

		["The best", "The most fun", "The most original", "No Second Chances!",3],
	]
}

var lines = {
	"banter": [
		"That\'s right, we\'re bringing you exactly what daytime TV has needed for so long: another bloody game show.",
		"I\'m your host: an embittered washing machine salesman whose agent convinced him this would be his big break."
	],
	"candidate_banter": [
		"Behold: an assort ment of people who didn\'t need to be anywhere else at 10 o\' clock on a Monday morning.",
		"Ah yes, the unmistakable signs of top tier university graduates. The country\'s finest minds on subjects ranging all the way from media studies to mouthbreathing.",
		"Oh. I\'m very sorry, there's clearly been a mistake. This is a quiz show, not Meet the Family with Mr. Baldrick."
	],
	"interlude": [
		"No sense wasting time. Let’s get on with it."
	],
	"first_question": [
		"So let’s get started with our first question!",
		"Here’s your first question. Protip: don’t bottle it.",
		"We start as we mean to go on, with a question whose answer should be obvious to all except those living under particularly large rocks."
	],
	"see_answers": [
		"Alright, let’s see everyone's answers.",
		"Let’s see what our prestigious players came up with.",
		"First of all, thank you to whoever submitted their answer in crayon. And for the accompanying image, which I’m afraid we can’t show on air"
	],
	"wrong": [
		"Oh no! Your answer was wrong.",
		"Oh, you were this close, which incidentally, is about thiiis far.",
		"And with that, the fate of the hapless contender is sealed. By which I mean you are wrong."
	],
	"welcome": [
		"Hello and welcome to \"No Second Chances\", the quizshow without mercy!",
		"Hello and welcome to \"No Second Chances\", the show where there are no stupid questions, just stupid panelists."
		]
}

func get_line(l):
	var idx = data.attempt_numero % lines[l].size()
	return lines[l][idx]
