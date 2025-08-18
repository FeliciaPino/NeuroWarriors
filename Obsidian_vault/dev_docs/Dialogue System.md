The dialogue system will allow the display of characters speech in sequence in reaction to: Interacting with the environment
Entering a trigger zone

It will also allow for narration when interacting with things, (such as Undertale's narration)

Dialogue will only be able to be seen outside of battle, so it there could feasible just be a dialogue manager per Room.

When displayed, there will be a text box on the bottom of the screen, showing the text. If there is a speaker (Most cases), it will also display their name and a portrait showing them and their expression (emotion).

The position of the portrait will vary depending on the speaker, with a back and forth between two parties, one speaker will be on the left and the other on the right.

If a player character that is not currently in the party speaks, their portrait will be shown through a screen, indicating that they are on a video call.


The system must be robust, allowing for diverse variations and reactions to the player's actions. 

##### Example 1
	Neuro (Angry): "Vedal is a dummy!"
	if Vedal is in the party:
		Anny(worried): "erm"
		Neuro(thoughtful): "he's right behind me, isn't he?"
		if Vedal is before Neuro by walk order:
			Vedal(Angry): "Actually, I am in front of you"


If many possible characters could feasibly have the same reaction, the first one that is in the party will speak, increasing immersion. 
##### Example 2

	Narrator: "The small bunny, protecting her family, chases you away with a hose"
	if there is a robotic character in the party:
		Robotic character in party (ashamed): "I'm not one of the mean robots!"
	else:
		First character in party (ashamed): "I'm not with the mean robots!"


So, the dialogue will be stored in a json, a list of objects. Each of these objects will have: an id, a speaker, an expression, text (the translation key), and the id of the next line. 

The dialogue manager will start with the line with id "start", this first line will work as an entry point and will not be displayed, instead, it will jump straight to its "next".

If the dialogue line has a a list for its "next" property, then it's branching. Each object of this list will have a condition and an id. The id associated with the first condition evaluated as true, will be selected as the next line of dialogue. The condition will be an expression (not facial expression, the thing with code) that returns a boolean that can be parsed using Expression, with a base instance of the DialogueManager class (meaning any of its functions may be used). The last object of this list of options will just be an id, the fall through in case all the conditions are false. Think of it as an if else chain.

##### Example JSON

[
	{
		"id":"start",
		"next":"line1"
	},
	{
		"id":"line1",
		"speaker":"Neuro-sama",
		"expression":"happy",
		"text_key":"DIALOGUE_1",
		"next":"line2"
	},
	{
		"id":"line2",
		"speaker":"Neuro-sama",
		"expression":"angry",
		"text_key":"DIALOGUE_2",
		"next":[
			{"condition":"GameState.party.has('Vedal')", "next":"vedal_in_party"},
			{"next":"no_vedal"}
		]
	},
	{
		"id":"vedal_in_party",
		"speaker":"Vedal",
		"expression":"neutral",
		"text_key":"DIALOGUE_3",
		"next":"last_line"
	},
	{
		"id":"no_vedal",
		"speaker":"Evil",
		"expression":"thoughtful",
		"next":"last_line"
	},
	{
		"id":"last_line",
		"speaker":"Anny",
		"expression":"happy",
		"text_key":"DIALOGUE_4",
	}
]

A line of dialogue may have a list associated to "speaker", in which case the first name that is in the party will be used as the speaker.

***Example

	{
		"id":"line1",
		"speaker":["Evil","Neuro-sama"],
		"expression":"Neutral",
		"text_key":"My father is Vedal.",
		"next":"line2"
	}

(In an actual example the text key would be a translation key to the dialogue instead of the dialogue itself)

The speed at which the text is written on screen can be modified adding a speed parameter like so:

{
	 "id":"line2",
	 "speaker":"Neuro-sama",
	 "expression":"Happy",
	 "speed":50,
	 "text_key":"look how fast I can speak!",
	 "next":"line3"
}

	The speed is measured in characters per second, the default speed is 25.