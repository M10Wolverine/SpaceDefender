note
	description: "Summary description for {SCORING}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SCORING

feature --score constants
	bronze: INTEGER=1
	silver: INTEGER=2
	gold: INTEGER=3

	platinum: INTEGER=3
	diamond: INTEGER=4

feature --add/get score feature
	add_score(s: SCORING):BOOLEAN
	deferred
	end

	get_score: INTEGER
	deferred
	end

end
